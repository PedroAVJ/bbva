#!/usr/bin/env python3
"""Guarded local storage for personal bank records."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath


SCHEMA_VERSION = 1
DEFAULT_STORE = Path.home() / "Library" / "Application Support" / "com.pedroavj.bbva" / "PrivateStore"


class StoreError(RuntimeError):
    pass


def store_path(value: str | None) -> Path:
    override = value or os.environ.get("BANK_PRIVATE_STORE")
    return Path(override).expanduser().resolve() if override else DEFAULT_STORE


def safe_relative_path(value: str) -> Path:
    candidate = PurePosixPath(value)
    if candidate.is_absolute() or not candidate.parts or any(part in {"", ".", ".."} for part in candidate.parts):
        raise StoreError(f"unsafe store-relative path: {value}")
    return Path(*candidate.parts)


def manifest_path(root: Path) -> Path:
    return root / "manifest.json"


def load_manifest(root: Path) -> dict:
    path = manifest_path(root)
    if not path.exists():
        raise StoreError(f"store is not initialized: {root}")
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise StoreError(f"cannot read store manifest: {error}") from error
    if payload.get("schemaVersion") != SCHEMA_VERSION or not isinstance(payload.get("entries"), dict):
        raise StoreError("unsupported or malformed store manifest")
    return payload


def write_manifest(root: Path, payload: dict) -> None:
    root.mkdir(parents=True, exist_ok=True, mode=0o700)
    temporary = root / ".manifest.json.tmp"
    temporary.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    temporary.chmod(0o600)
    temporary.replace(manifest_path(root))


def initialize(root: Path) -> None:
    root.mkdir(parents=True, exist_ok=True, mode=0o700)
    root.chmod(0o700)
    (root / "records").mkdir(exist_ok=True, mode=0o700)
    if not manifest_path(root).exists():
        write_manifest(root, {"schemaVersion": SCHEMA_VERSION, "entries": {}})


def digest(path: Path) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            hasher.update(block)
    return hasher.hexdigest()


def iter_source_files(source: Path) -> list[Path]:
    if source.is_symlink():
        raise StoreError(f"symbolic links are not imported: {source}")
    if source.is_file():
        return [source]
    if not source.is_dir():
        raise StoreError(f"source does not exist: {source}")
    files = []
    for path in sorted(source.rglob("*")):
        if path.is_symlink():
            raise StoreError(f"symbolic links are not imported: {path}")
        if path.is_file():
            files.append(path)
    return files


def import_files(root: Path, source: Path, destination: Path, provenance_root: Path,
                 repository: str, revision: str, replace: bool = False) -> int:
    initialize(root)
    manifest = load_manifest(root)
    source = source.resolve()
    provenance_root = provenance_root.resolve()
    files = iter_source_files(source)
    imported_at = datetime.now(timezone.utc).isoformat()
    plans = []

    for input_path in files:
        try:
            provenance_relative = input_path.relative_to(provenance_root).as_posix()
        except ValueError as error:
            raise StoreError(f"source is outside provenance root: {input_path}") from error
        suffix = Path(input_path.name) if source.is_file() else input_path.relative_to(source)
        relative_output = destination / suffix
        output_path = root / relative_output
        source_digest = digest(input_path)
        if output_path.exists() and digest(output_path) != source_digest and not replace:
            raise StoreError(f"destination exists with different contents: {relative_output.as_posix()}")
        plans.append((input_path, output_path, relative_output.as_posix(), provenance_relative, source_digest))

    for input_path, output_path, manifest_key, provenance_relative, source_digest in plans:
        output_path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        if not output_path.exists() or digest(output_path) != source_digest:
            shutil.copy2(input_path, output_path)
        output_path.chmod(0o600)
        manifest["entries"][manifest_key] = {
            "bytes": output_path.stat().st_size,
            "importedAt": imported_at,
            "provenance": {
                "repository": repository,
                "revision": revision,
                "relativePath": provenance_relative,
            },
            "sha256": source_digest,
        }
    write_manifest(root, manifest)
    return len(plans)


def verify(root: Path) -> list[str]:
    manifest = load_manifest(root)
    errors = []
    for key, entry in sorted(manifest["entries"].items()):
        try:
            relative = safe_relative_path(key)
        except StoreError as error:
            errors.append(str(error))
            continue
        path = root / relative
        if not path.is_file():
            errors.append(f"missing: {key}")
            continue
        if path.stat().st_size != entry.get("bytes"):
            errors.append(f"size mismatch: {key}")
        if digest(path) != entry.get("sha256"):
            errors.append(f"checksum mismatch: {key}")
        provenance = entry.get("provenance")
        if not isinstance(provenance, dict) or not all(provenance.get(field) for field in ("repository", "revision", "relativePath")):
            errors.append(f"invalid provenance: {key}")
    return errors


def read_text(root: Path, relative: Path) -> str:
    manifest = load_manifest(root)
    key = relative.as_posix()
    if key not in manifest["entries"]:
        raise StoreError(f"path is not recorded in the manifest: {key}")
    path = root / relative
    if digest(path) != manifest["entries"][key]["sha256"]:
        raise StoreError(f"checksum mismatch: {key}")
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError as error:
        raise StoreError(f"record is binary; use its private-store path directly: {key}") from error


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(prog="bank-store", description=__doc__)
    result.add_argument("--store", help="override the private store root")
    commands = result.add_subparsers(dest="command", required=True)
    commands.add_parser("init", help="initialize the private store")
    commands.add_parser("path", help="print the private store root")
    commands.add_parser("list", help="list manifest paths without record contents")
    commands.add_parser("verify", help="verify checksums and provenance")
    importer = commands.add_parser("import", help="import a file or directory with provenance")
    importer.add_argument("--source", required=True)
    importer.add_argument("--destination", required=True, help="store-relative destination directory")
    importer.add_argument("--provenance-root", required=True)
    importer.add_argument("--repository", required=True)
    importer.add_argument("--revision", required=True)
    importer.add_argument("--replace", action="store_true")
    reader = commands.add_parser("read", help="read a manifest-recorded UTF-8 text file")
    reader.add_argument("--record", required=True, help="store-relative record path")
    return result


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    root = store_path(args.store)
    try:
        if args.command == "init":
            initialize(root)
            print(root)
        elif args.command == "path":
            print(root)
        elif args.command == "list":
            for key in sorted(load_manifest(root)["entries"]):
                print(key)
        elif args.command == "verify":
            errors = verify(root)
            if errors:
                for error in errors:
                    print(error, file=sys.stderr)
                return 1
            print(f"verified {len(load_manifest(root)['entries'])} records")
        elif args.command == "import":
            count = import_files(root, Path(args.source), safe_relative_path(args.destination),
                                 Path(args.provenance_root), args.repository, args.revision, args.replace)
            print(f"imported {count} records")
        elif args.command == "read":
            sys.stdout.write(read_text(root, safe_relative_path(args.record)))
        return 0
    except (OSError, StoreError) as error:
        print(f"bank-store: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
