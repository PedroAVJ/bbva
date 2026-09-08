import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[2] / "script" / "dashboard_db.py"
SPEC = importlib.util.spec_from_file_location("dashboard_db", SCRIPT)
dashboard_db = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(dashboard_db)


class DashboardDatabaseTests(unittest.TestCase):
    def test_expenses_can_be_added_and_moved_without_rebuilding(self):
        with tempfile.TemporaryDirectory() as directory:
            database = Path(directory) / "dashboard.sqlite3"
            snapshot = {
                "schemaVersion": 1,
                "dataMode": "private",
                "asOfDate": "2026-01-15",
                "dateLabel": "Synthetic test · Jan 15",
                "currency": "MXN",
                "balanceMxn": -100,
                "dailyCreditMxn": 100,
                "spentTodayMxn": 50,
                "typicalSlackDailyMxn": 10,
                "incomeMonthlyMxn": 30000,
                "typicalVariableMonthlyMxn": 9000,
                "outlierNote": "synthetic test outlier",
                "dailyNetsMxn": [0] * 14,
                "categories": [
                    {
                        "id": "health",
                        "name": "Health",
                        "subtitle": "",
                        "monthlyMxn": 100,
                        "color": "#3A6EA8",
                        "note": "",
                        "footnote": "",
                        "items": [{"name": "Medication", "monthlyMxn": 100}],
                    },
                    {
                        "id": "other",
                        "name": "Other fixed",
                        "subtitle": "",
                        "monthlyMxn": 159,
                        "color": "#C7E1F8",
                        "note": "",
                        "footnote": "",
                        "items": [{"name": "Video Service", "monthlyMxn": 159}],
                    },
                ],
            }
            dashboard_db.replace_snapshot(database, snapshot)
            dashboard_db.upsert_expense(database, "Video Service", 159, "Health")
            dashboard_db.upsert_expense(database, "Music Service", 139, "Health")

            updated = dashboard_db.verify(database)
            health = next(category for category in updated["categories"] if category["id"] == "health")
            other = next(category for category in updated["categories"] if category["id"] == "other")
            self.assertEqual(health["monthlyMxn"], 398)
            self.assertEqual(other["monthlyMxn"], 0)
            self.assertEqual(
                [item["name"] for item in health["items"]],
                ["Medication", "Video Service", "Music Service"],
            )


if __name__ == "__main__":
    unittest.main()
