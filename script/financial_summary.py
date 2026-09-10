#!/usr/bin/env python3
"""Calculate financial net worth and monthly net cash run rate from reviewed records."""
import argparse
from decimal import Decimal, InvalidOperation
import json
from pathlib import Path
import sys

FACTORS = {'weekly': Decimal(52) / 12, 'biweekly': Decimal(26) / 12,
           'monthly': Decimal(1), 'yearly': Decimal(1) / 12}
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


def calculate(data):
    if data.get('schema_version') != 1:
        raise ValueError('schema_version must be 1')
    for field in ('as_of', 'period', 'currency'):
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

    assets = sum((v for _, v in entries('assets', ASSETS)), Decimal(0))
    debts = sum((v for _, v in entries('debts', DEBTS)), Decimal(0))
    totals = {}
    lines = []
    for key, categories in [('income', {'cash_income'}), ('outgoings', EXPENSES)]:
        total = Decimal(0)
        for row, value in entries(key, categories):
            frequency = row.get('frequency')
            if frequency not in FACTORS:
                raise ValueError(f'unsupported frequency: {frequency}')
            monthly = value * FACTORS[frequency]
            total += monthly
            lines.append({'id': row['id'], 'kind': key, 'monthly_amount': money(monthly),
                          'status': row['status'], 'source': row['source']})
        totals[key] = total
    if estimated and not data['assumptions']:
        raise ValueError('estimated entries require disclosed assumptions')
    return {'schema_version': 1, 'as_of': data['as_of'], 'period': data['period'],
            'currency': data['currency'], 'financial_net_worth': money(assets - debts),
            'monthly_cash_income': money(totals['income']),
            'monthly_cash_outgoings': money(totals['outgoings']),
            'monthly_net_cash_run_rate': money(totals['income'] - totals['outgoings']),
            'estimated_entries': estimated, 'assumptions': data['assumptions'],
            'monthly_components': lines}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input', required=True, type=Path,
                        help='reviewed JSON record; keep personal inputs in the private store')
    args = parser.parse_args()
    try:
        result = calculate(json.loads(args.input.read_text()))
    except (OSError, ValueError, KeyError, TypeError, AttributeError) as error:
        print(f'financial-summary: {error}', file=sys.stderr)
        return 2
    print(json.dumps(result, indent=2))
    return 0


if __name__ == '__main__':
    sys.exit(main())
