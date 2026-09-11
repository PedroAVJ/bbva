import copy
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / 'script/financial_summary.py'
spec = importlib.util.spec_from_file_location('summary', SCRIPT)
summary = importlib.util.module_from_spec(spec)
spec.loader.exec_module(summary)


def row(identifier, category, value, frequency=None):
    entry = dict(id=identifier, category=category, amount=value,
                 source='synthetic fixture', status='confirmed')
    if frequency:
        entry['frequency'] = frequency
    return entry


def fixture():
    return dict(schema_version=1, as_of='2026-01-31', period='January 2026',
                currency='MXN', assumptions=[],
                assets=[row('bank', 'bank', '10000'), row('cash', 'cash', '500')],
                debts=[row('card', 'card_total', '6000'), row('parent-debt', 'family', '3000')],
                income=[row('pay', 'cash_income', '3000', 'weekly')],
                outgoings=[row('living', 'spending', '8000', 'monthly'),
                           row('parents', 'family_repayment', '500', 'weekly'),
                           row('installment', 'installment', '1500', 'monthly'),
                           row('tax', 'tax_payment', '2000', 'monthly')])


class SummaryTests(unittest.TestCase):
    def test_repayments_can_turn_positive_income_negative(self):
        result = summary.calculate(fixture())
        self.assertEqual(result['financial_net_worth'], '1500.00')
        self.assertEqual(result['monthly_cash_income'], '13000.00')
        self.assertEqual(result['monthly_net_cash_run_rate'], '-666.67')

    def test_card_total_does_not_change_run_rate(self):
        data = fixture()
        data['debts'][0]['amount'] = '16000'
        result = summary.calculate(data)
        self.assertEqual(result['financial_net_worth'], '-8500.00')
        self.assertEqual(result['monthly_net_cash_run_rate'], '-666.67')

    def test_rejects_physical_asset_and_card_settlement(self):
        for collection, category in [('assets', 'computer'), ('outgoings', 'card_settlement')]:
            data = fixture()
            data[collection][0]['category'] = category
            with self.assertRaises(ValueError):
                summary.calculate(data)

    def test_missing_and_duplicate_rows_fail(self):
        for collection in ['assets', 'debts', 'income', 'outgoings']:
            data = fixture()
            data[collection] = []
            with self.assertRaises(ValueError):
                summary.calculate(data)
        data = fixture()
        data['outgoings'].append(copy.deepcopy(data['outgoings'][0]))
        with self.assertRaises(ValueError):
            summary.calculate(data)

    def test_estimates_must_be_disclosed(self):
        data = fixture()
        data['income'][0]['status'] = 'estimated'
        with self.assertRaises(ValueError):
            summary.calculate(data)
        data['assumptions'] = ['Pay cadence assumed unchanged.']
        self.assertEqual(summary.calculate(data)['estimated_entries'], ['pay'])

    def test_invalid_amounts(self):
        for value in ['NaN', 'Infinity', '-1', True, None]:
            data = fixture()
            data['assets'][0]['amount'] = value
            with self.assertRaises(ValueError):
                summary.calculate(data)

    def test_cli_entrypoint(self):
        artifacts = ROOT / '.codex-artifacts'
        artifacts.mkdir(exist_ok=True)
        with tempfile.TemporaryDirectory(dir=artifacts) as folder:
            path = Path(folder) / 'synthetic.json'
            path.write_text(json.dumps(fixture()))
            run = subprocess.run([sys.executable, str(SCRIPT), '--input', str(path)],
                                 text=True, capture_output=True)
            self.assertEqual(run.returncode, 0, run.stderr)
            self.assertEqual(json.loads(run.stdout)['monthly_net_cash_run_rate'], '-666.67')
            data = fixture()
            data['outgoings'][0]['category'] = 'depreciation'
            path.write_text(json.dumps(data))
            run = subprocess.run([sys.executable, str(SCRIPT), '--input', str(path)],
                                 text=True, capture_output=True)
            self.assertEqual(run.returncode, 2)
            self.assertEqual(run.stdout, '')

    def test_metrics_do_not_require_each_others_records(self):
        balance_sheet = fixture()
        for key in ('income', 'outgoings', 'period'):
            del balance_sheet[key]
        worth = summary.calculate(balance_sheet, 'net-worth')
        self.assertEqual(worth['financial_net_worth'], '1500.00')
        self.assertNotIn('monthly_net_cash_run_rate', worth)
        cash = fixture()
        del cash['assets']
        del cash['debts']
        run_rate = summary.calculate(cash, 'net-cash-run-rate')
        self.assertEqual(run_rate['monthly_net_cash_run_rate'], '-666.67')
        self.assertNotIn('financial_net_worth', run_rate)

    def test_four_weekly_purchase_and_annual_reserve_rank_once(self):
        data = fixture()
        data['outgoings'] = [row('renewal', 'annual_reserve', '1200', 'yearly'),
                             row('supplies', 'spending', '120', 'four_weekly')]
        data['outgoings'][1]['label'] = 'Supplies'
        result = summary.calculate(data, 'net-cash-run-rate')
        self.assertEqual(result['monthly_cash_outgoings'], '230.00')
        self.assertEqual([r['id'] for r in result['ranked_monthly_outgoings']],
                         ['supplies', 'renewal'])
        self.assertEqual(result['ranked_monthly_outgoings'][0]['label'], 'Supplies')

    def test_single_metric_cli_entrypoints(self):
        artifacts = ROOT / '.codex-artifacts'
        artifacts.mkdir(exist_ok=True)
        with tempfile.TemporaryDirectory(dir=artifacts) as folder:
            path = Path(folder) / 'synthetic.json'
            for metric, remove, output in [
                    ('net-worth', ('income', 'outgoings', 'period'), 'financial_net_worth'),
                    ('net-cash-run-rate', ('assets', 'debts'), 'monthly_net_cash_run_rate')]:
                data = fixture()
                for key in remove:
                    del data[key]
                path.write_text(json.dumps(data))
                run = subprocess.run([sys.executable, str(SCRIPT), '--metric', metric,
                                      '--input', str(path)], text=True, capture_output=True)
                self.assertEqual(run.returncode, 0, run.stderr)
                self.assertIn(output, json.loads(run.stdout))
            data['outgoings'] = []
            path.write_text(json.dumps(data))
            run = subprocess.run([sys.executable, str(SCRIPT), '--metric', 'net-cash-run-rate',
                                  '--input', str(path)], text=True, capture_output=True)
            self.assertEqual(run.returncode, 2)
            self.assertEqual(run.stdout, '')
