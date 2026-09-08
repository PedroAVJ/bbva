import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class PluginMetadataTests(unittest.TestCase):
    def test_plugin_identity_is_bbva_in_both_clients(self):
        codex = json.loads((ROOT / ".codex-plugin" / "plugin.json").read_text(encoding="utf-8"))
        claude = json.loads((ROOT / ".claude-plugin" / "plugin.json").read_text(encoding="utf-8"))

        self.assertEqual(codex["name"], "bbva")
        self.assertEqual(codex["interface"]["displayName"], "BBVA")
        self.assertEqual(codex["version"], claude["version"])

    def test_skill_display_name_is_bbva(self):
        metadata = (ROOT / "skills" / "bank" / "agents" / "openai.yaml").read_text(
            encoding="utf-8"
        )
        self.assertIn('display_name: "BBVA"', metadata)
        self.assertNotIn('display_name: "Bank"', metadata)


if __name__ == "__main__":
    unittest.main()
