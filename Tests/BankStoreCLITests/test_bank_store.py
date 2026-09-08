import importlib.util
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[2] / "script" / "bank_store.py"
SPEC = importlib.util.spec_from_file_location("bank_store", SCRIPT)
bank_store = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(bank_store)


class BankStoreTests(unittest.TestCase):
    def test_import_read_and_verify_preserve_provenance(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source_root = root / "source"
            source_root.mkdir()
            source = source_root / "record.md"
            source.write_text("private record\n", encoding="utf-8")
            store = root / "store"
            count = bank_store.import_files(store, source, Path("records/context"), source_root,
                                            "example/repository", "deadbeef")
            self.assertEqual(count, 1)
            self.assertEqual(bank_store.verify(store), [])
            self.assertEqual(bank_store.read_text(store, Path("records/context/record.md")), "private record\n")
            provenance = bank_store.load_manifest(store)["entries"]["records/context/record.md"]["provenance"]
            self.assertEqual(provenance["relativePath"], "record.md")
            self.assertEqual(provenance["revision"], "deadbeef")

    def test_verify_detects_tampering(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "record.md"
            source.write_text("original\n", encoding="utf-8")
            store = root / "store"
            bank_store.import_files(store, source, Path("records"), root, "repo", "revision")
            (store / "records" / "record.md").write_text("changed\n", encoding="utf-8")
            self.assertTrue(any("mismatch" in error for error in bank_store.verify(store)))

    def test_rejects_path_traversal(self):
        with self.assertRaises(bank_store.StoreError):
            bank_store.safe_relative_path("../outside")


if __name__ == "__main__":
    unittest.main()
