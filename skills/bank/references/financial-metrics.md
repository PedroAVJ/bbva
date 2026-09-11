# Financial net worth and monthly net cash run rate

These are two independent personal-management metrics. A request for one does
not require refreshing the other. “Net run rate” or “normalized monthly cash
flow” names the monthly measure. When the user informally calls it net income,
answer the intended cash question; do not substitute accounting net income.

## Financial net worth at a timestamp

Bank balances + cash held + supported collectible receivables − all outstanding
debt. Include the full card debt, including future installments, once; family
loans, cash advances and tax debt also count. Do not add computers, cars or other
physical possessions as assets. A repayment received in cash replaces the
receivable; it does not create another asset. Mark uncertain cash/receivables
explicitly, and never silently carry stale balances as verified current.

## Monthly net cash run rate

Monthly recurring take-home cash income − monthly cash spending and payment
commitments. Weekly ×52/12; every two weeks ×26/12; every four weeks ×13/12;
annual /12; monthly unchanged.
Do not confuse twice-monthly with every two weeks. Variable income requires an
explicit supported averaging window, not an assumed paycheck. One-off receipts
are not recurring income. Use the selected completed billing cycle as one monthly
spending sample; disclose that convention and do not silently mix it with a
calendar-day accrual rate.

Include everyday spending, subscription cash charges, tax payments, interest,
card installments, family repayments and other loan repayments. Principal DOES
count here. For financed purchases count the scheduled installment, not the full
purchase cost and not useful-life depreciation. For outright purchases include
the cash cost in the historical spending sample and identify material one-offs;
never invent a useful life to smooth them. Annual recurring bills can be shown
as monthly reserves instead of their full annual charge, explicitly and once.

For a forward working estimate, include everyday variable purchases even when
personal allocation or exact replacement cadence remains estimated. Show gross
shared portions and the source of uncertainty; do not make the working total
artificially incomplete by excluding all food or household goods. Known spending
for others is separate unless funded by explicit choice; existing family debt
repayments remain obligations. Rank individual expenses by monthly amount,
grouping only useful repeat purposes such as rides or one vendor's usage.

Predictable irregular purchases can use a supported allowance or sinking-fund
reserve. Keep genuine exceptional one-offs separately visible. Do not both
reserve for a purchase and count it again in the same baseline. Disclose the
estimation window and any unquantified costs; an estimated amount is not exact,
and an unknown amount is not zero. Show future price changes and debt endings
separately from currently payable rates.

Count each cash requirement once. If card purchases and installment charges are
included, exclude bank-to-card settlements. If using aggregate non-card outgoings
from balances, family/tax/loan payments may already be inside that residual:
do not add them again. Treat a repayment-cadence normalization as replacement of
the observed amount, not a second expense. Exclude own-account transfers and
loan advances to others from consumption; disclose their separate liquidity
impact. Refunds/reimbursements need matching treatment and must not be assumed
recurring salary. Separate principal from interest only to avoid counting either
twice, never to drop principal from cash outgoings.

## Evidence order and reconciliation

1. Read the private store's account roles, income cadence, recurring register,
   statements and latest snapshots. Use original purchase/loan amounts only for
   outstanding debt; use the actual installment schedule for run rate.
2. Prefer complete transaction coverage. When statements lag, use observed
   opening/closing balances and known receipts/payments before extrapolating a
   prior month's cash/debit spending. Do not claim a missing PDF makes an
   aggregate estimate impossible. Identify every account and timestamp covered.
3. Balance inference: net non-card outgoings = cash/payroll receipts − change in
   tracked bank/cash/receivable assets − bank-to-card payments. Separate other
   receipts/borrowing and investment/loan transfers before treating the result
   as spending. Card refunds are not bank-to-card payments. If deposits are
   inferred from cadence, mark them estimated. Reconcile asset movements and
   installment balances; do not describe unexplained residuals as verified costs.
4. Replace paycheck-count timing with the recurring monthly income rate only
   after reconstructing period cash movements. A month with an extra payday
   can have a positive cash change and a negative monthly run rate.
5. Use an exact cutoff where available; disclose mismatched snapshot dates and
   adjust supported out-of-period movements. Keep balances, recurring rates,
   reporting windows and their confidence visible. Do not promise a numerical
   worst-case error bound without evidence that bounds every material unknown.
6. If revising a published figure, bridge the old result to the new one using
   amount, changed inclusion, frequency, date cutoff or new evidence. Never
   silently substitute net-worth change, accounting income or actual deposits
   for net cash run rate.

## Private review continuity

When present, `records/financial-summary/review-index.json` points to the current
methodology, correction decisions, independent net-worth snapshot and run-rate
input/report. Read the relevant pointers before rebuilding an existing review.
Preserve dates, provenance, uncertain allocations and explicitly superseded
figures. A historical merchant description alone is weaker than a matching
invoice identifying a final bill for a canceled service.

Persist dated inputs and results through `script/bank_store.py import` with
provenance, then verify the store. Keep prior records and replace only the index
or current pointer with `--replace` when updating it. An index update for one
metric must preserve the other metric's independent pointer. JSON records in
the existing store are sufficient; a new database is not required.

## Reviewed input and calculator

Write personal inputs/results only in PrivateStore/records/financial-summary/.
The plugin package contains procedures and synthetic tests, never live records.
Run from the plugin root:

```sh
python3 script/financial_summary.py --metric net-worth --input /absolute/private/net-worth-input.json
python3 script/financial_summary.py --metric net-cash-run-rate --input /absolute/private/run-rate-input.json
python3 script/financial_summary.py --input /absolute/private/combined-input.json
```

Input schema version 1 has `as_of`, `currency`, and `assumptions` (list).
`--metric net-worth` requires only `assets` and `debts` entry lists;
`--metric net-cash-run-rate` requires `period`, `income` and `outgoings`.
The default `--metric both` retains the combined mode requiring all four lists
and `period`. Fields for the other metric are neither required nor calculated
in a single-metric mode.

Required lists must be nonempty. Each entry has
unique `id`, nonnegative decimal-string `amount`, `category`, `source` and
`status` (`confirmed` or `estimated`). Income/outgoing entries also have
`frequency`: weekly, biweekly, four_weekly, monthly or yearly. An optional `label`
preserves the user-facing item name in monthly output and ranked outgoings.
Use `monthly` for already normalized estimates and disclose their original
cadence or averaging window in the source/assumptions. Supply an explicit zero entry
for a reviewed empty category; missing data is not zero. All amounts must be in
the stated currency; record any conversion source in assumptions.

Allowed asset categories: bank, cash, receivable. Debt categories: card_total,
loan, family, tax, other_debt. Income: cash_income. Outgoings: spending,
subscription, installment, interest, family_repayment, loan_repayment,
tax_payment, annual_reserve. Consolidate overlapping rows first; IDs prevent
literal duplication but cannot detect the same obligation under different IDs.
Use a monthly `spending` entry for a reconciled residual and explain all included
repayments in its source/assumptions. Never add those payments again separately.

The calculator performs transparent arithmetic on reviewed inputs; it does not
claim to classify bank transactions automatically. Inspect its components and
assumptions. Present the requested metric: net worth at its timestamp, or monthly
cash in, monthly cash out and net cash run rate for the stated window, followed
by material uncertainty. Show both only when the request calls for both.
