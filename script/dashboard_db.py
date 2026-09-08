#!/usr/bin/env python3
"""Maintain the BBVA dashboard snapshot without rebuilding the macOS app."""

from __future__ import annotations

import argparse
import json
import os
import sqlite3
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


DEFAULT_DATABASE = (
    Path.home()
    / "Library"
    / "Application Support"
    / "com.pedroavj.bbva"
    / "PrivateStore"
    / "dashboard.sqlite3"
)


class DashboardDatabaseError(RuntimeError):
    pass


def _validate_snapshot(snapshot: dict[str, Any]) -> None:
    required = {
        "schemaVersion",
        "dataMode",
        "asOfDate",
        "dateLabel",
        "currency",
        "balanceMxn",
        "dailyCreditMxn",
        "spentTodayMxn",
        "typicalSlackDailyMxn",
        "incomeMonthlyMxn",
        "typicalVariableMonthlyMxn",
        "outlierNote",
        "dailyNetsMxn",
        "categories",
    }
    missing = sorted(required.difference(snapshot))
    if missing:
        raise DashboardDatabaseError(f"snapshot is missing: {', '.join(missing)}")
    if len(snapshot["dailyNetsMxn"]) != 14:
        raise DashboardDatabaseError("dailyNetsMxn must contain 14 values")
    if not snapshot["categories"]:
        raise DashboardDatabaseError("snapshot must contain categories")

    category_ids: set[str] = set()
    item_names: set[str] = set()
    for category in snapshot["categories"]:
        category_id = str(category.get("id", "")).strip().casefold()
        if not category_id or category_id in category_ids:
            raise DashboardDatabaseError("category ids must be non-empty and unique")
        category_ids.add(category_id)
        for item in category.get("items", []):
            item_name = str(item.get("name", "")).strip().casefold()
            if not item_name or item_name in item_names:
                raise DashboardDatabaseError("expense names must be non-empty and unique")
            item_names.add(item_name)


def _connect(database_path: Path) -> sqlite3.Connection:
    database_path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    os.chmod(database_path.parent, 0o700)
    connection = sqlite3.connect(database_path)
    connection.execute(
        """
        CREATE TABLE IF NOT EXISTS dashboard_snapshot (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            schema_version INTEGER NOT NULL,
            payload TEXT NOT NULL,
            updated_at TEXT NOT NULL
        )
        """
    )
    return connection


def replace_snapshot(database_path: Path, snapshot: dict[str, Any]) -> None:
    _validate_snapshot(snapshot)
    payload = json.dumps(snapshot, ensure_ascii=False, separators=(",", ":"))
    updated_at = datetime.now(timezone.utc).isoformat()
    with _connect(database_path) as connection:
        connection.execute(
            """
            INSERT INTO dashboard_snapshot (id, schema_version, payload, updated_at)
            VALUES (1, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
                schema_version = excluded.schema_version,
                payload = excluded.payload,
                updated_at = excluded.updated_at
            """,
            (int(snapshot["schemaVersion"]), payload, updated_at),
        )
    os.chmod(database_path, 0o600)


def read_snapshot(database_path: Path) -> dict[str, Any]:
    if not database_path.exists():
        raise DashboardDatabaseError(f"database does not exist: {database_path}")
    with sqlite3.connect(f"file:{database_path}?mode=ro", uri=True) as connection:
        row = connection.execute(
            "SELECT payload FROM dashboard_snapshot WHERE id = 1"
        ).fetchone()
    if row is None:
        raise DashboardDatabaseError("database has no active dashboard snapshot")
    snapshot = json.loads(row[0])
    _validate_snapshot(snapshot)
    return snapshot


def upsert_expense(
    database_path: Path,
    name: str,
    monthly_mxn: float,
    category_key: str,
) -> None:
    if monthly_mxn < 0:
        raise DashboardDatabaseError("monthly amount cannot be negative")
    snapshot = read_snapshot(database_path)
    categories = snapshot["categories"]
    wanted = category_key.strip().casefold()
    target = next(
        (
            category
            for category in categories
            if wanted in {
                str(category["id"]).casefold(),
                str(category["name"]).casefold(),
            }
        ),
        None,
    )
    if target is None:
        raise DashboardDatabaseError(f"unknown category: {category_key}")

    wanted_name = name.strip().casefold()
    for category in categories:
        retained = []
        for item in category["items"]:
            if str(item["name"]).strip().casefold() == wanted_name:
                category["monthlyMxn"] = round(
                    float(category["monthlyMxn"]) - float(item["monthlyMxn"]), 2
                )
            else:
                retained.append(item)
        category["items"] = retained

    target["items"].append({"name": name.strip(), "monthlyMxn": monthly_mxn})
    target["monthlyMxn"] = round(float(target["monthlyMxn"]) + monthly_mxn, 2)
    snapshot["dataMode"] = "private"
    replace_snapshot(database_path, snapshot)


def verify(database_path: Path) -> dict[str, Any]:
    snapshot = read_snapshot(database_path)
    with sqlite3.connect(f"file:{database_path}?mode=ro", uri=True) as connection:
        quick_check = connection.execute("PRAGMA quick_check").fetchone()[0]
    if quick_check != "ok":
        raise DashboardDatabaseError(f"SQLite quick check failed: {quick_check}")
    return snapshot


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--db", type=Path, default=DEFAULT_DATABASE)
    subparsers = parser.add_subparsers(dest="command", required=True)

    import_parser = subparsers.add_parser("import-json")
    import_parser.add_argument("snapshot", type=Path)

    expense_parser = subparsers.add_parser("upsert-expense")
    expense_parser.add_argument("name")
    expense_parser.add_argument("monthly_mxn", type=float)
    expense_parser.add_argument("category")

    subparsers.add_parser("verify")
    subparsers.add_parser("summary")
    return parser


def main() -> int:
    arguments = _parser().parse_args()
    try:
        if arguments.command == "import-json":
            snapshot = json.loads(arguments.snapshot.read_text(encoding="utf-8"))
            replace_snapshot(arguments.db, snapshot)
        elif arguments.command == "upsert-expense":
            upsert_expense(
                arguments.db,
                arguments.name,
                arguments.monthly_mxn,
                arguments.category,
            )
        else:
            snapshot = verify(arguments.db)
            if arguments.command == "summary":
                print(f"{snapshot['dateLabel']} · {snapshot['currency']}")
                for category in snapshot["categories"]:
                    print(f"{category['name']}: {category['monthlyMxn']:.2f}/mo")
            else:
                print(f"verified {len(snapshot['categories'])} categories")
    except (DashboardDatabaseError, json.JSONDecodeError, OSError, sqlite3.Error) as error:
        raise SystemExit(f"error: {error}") from error
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
