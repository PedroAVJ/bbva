#!/usr/bin/env python3
"""Calculate financial net worth and monthly net cash run rate from reviewed records."""
import argparse
from decimal import Decimal, InvalidOperation
import json
from pathlib import Path
import sys

FACTORS = {'weekly': Decimal(52) / 12, 'biweekly': Decimal(26) / 12,
           'four_weekly': Decimal(13) / 12, 'monthly': Decimal(1),
           'yearly': Decimal(1) / 12}
METRICS = ('both', 'net-worth', 'net-cash-run-rate')
ASSETS = {'bank', 'cash', 'receivable'}
DEBTS = {'card_total', 'loan', 'family', 'tax', 'other_debt'}
EXPENSES = {'spending', 'subscription', 'installment', 'interest',
            'family_repayment', 'loan_repayment', 'tax_payment', 'annual_reserve'}


def amount(value):
    if isinstance(value, bool):
        raise ValueError('amount must be a finite nonnegative decimal')
    try:
        number = Decimal(str(value))
    except InvalidOperation:
        raise ValueError('amount must be a decimal') from None
    if not number.is_finite() or number < 0:
        raise ValueError('amount must be finite and nonnegative')
    return number


def money(value):
    return str(value.quantize(Decimal('0.01')))


def calculate(data, metric='both'):
    if metric not in METRICS:
        raise ValueError(f'unsupported metric: {metric}')
    if data.get('schema_version') != 1:
        raise ValueError('schema_version must be 1')
    required = ['as_of', 'currency']
    if metric != 'net-worth':
        required.append('period')
    for field in required:
        if not isinstance(data.get(field), str) or not data[field].strip():
            raise ValueError(f'{field} is required')
    if not isinstance(data.get('assumptions'), list) or not all(
            isinstance(x, str) and x.strip() for x in data['assumptions']):
        raise ValueError('assumptions must be an explicit list of strings')
    ids, estimated = set(), []

    def entries(key, categories):
        if not isinstance(data.get(key), list) or not data[key]:
            raise ValueError(f'{key} must contain reviewed entries (explicit zero if none)')
        for row in data[key]:
            if not isinstance(row.get('id'), str) or not row['id'] or row['id'] in ids:
                raise ValueError('entry IDs must be nonempty and unique')
            ids.add(row['id'])
            if row.get('category') not in categories:
                raise ValueError(f"unsupported {key} category: {row.get('category')}")
            if not row.get('source') or row.get('status') not in ('confirmed', 'estimated'):
                raise ValueError('each entry needs source and confirmed/estimated status')
            if row['status'] == 'estimated':
                estimated.append(row['id'])
            yield row, amount(row.get('amount'))

    result = {'schema_version': 1, 'metric': metric, 'as_of': data['as_of'],
              'currency': data['currency']}
    if metric != 'net-cash-run-rate':
        assets = sum((v for _, v in entries('assets', ASSETS)), Decimal(0))
        debts = sum((v for _, v in entries('debts', DEBTS)), Decimal(0))
        result.update(financial_assets=money(assets), financial_debts=money(debts),
                      financial_net_worth=money(assets - debts))
    if metric != 'net-worth':
        totals, lines = {}, []
        for key, categories in [('income', {'cash_income'}), ('outgoings', EXPENSES)]:
            total = Decimal(0)
            for row, value in entries(key, categories):
                frequency = row.get('frequency')
                if frequency not in FACTORS:
                    raise ValueError(f'unsupported frequency: {frequency}')
                monthly = value * FACTORS[frequency]
                total += monthly
                line = {'id': row['id'], 'kind': key, 'category': row['category'],
                        'monthly_amount': money(monthly), 'status': row['status'],
                        'source': row['source']}
                if row.get('label'):
                    line['label'] = row['label']
                lines.append(line)
            totals[key] = total
        result.update(period=data['period'], monthly_cash_income=money(totals['income']),
                      monthly_cash_outgoings=money(totals['outgoings']),
                      monthly_net_cash_run_rate=money(totals['income'] - totals['outgoings']),
                      monthly_components=lines,
                      ranked_monthly_outgoings=sorted(
                          (line for line in lines if line['kind'] == 'outgoings'),
                          key=lambda line: Decimal(line['monthly_amount']), reverse=True))
    if estimated and not data['assumptions']:
        raise ValueError('estimated entries require disclosed assumptions')
    result.update(estimated_entries=estimated, assumptions=data['assumptions'])
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input', required=True, type=Path,
                        help='reviewed JSON record; keep personal inputs in the private store')
    parser.add_argument('--metric', choices=METRICS, default='both',
                        help='calculate one metric without requiring the other metric inputs')
    args = parser.parse_args()
    try:
        result = calculate(json.loads(args.input.read_text()), args.metric)
    except (OSError, ValueError, KeyError, TypeError, AttributeError) as error:
        print(f'financial-summary: {error}', file=sys.stderr)
        return 2
    print(json.dumps(result, indent=2))
    return 0


if __name__ == '__main__':
    sys.exit(main())
