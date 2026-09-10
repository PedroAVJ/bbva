# Financial net worth and monthly net cash run rate

These are two distinct personal-management metrics. Do not call either an
accrual income statement, depreciation result, or generic "net income".
Keep the financial-net-worth balance sheet independent from the cash run rate.

## Financial net worth at a timestamp

Bank balances + cash held + supported collectible receivables − all outstanding
debt. Include the full card debt, including future installments, once; family
loans, cash advances and tax debt also count. Do not add computers, cars or other
physical possessions as assets. A repayment received in cash replaces the
receivable; it does not create another asset. Mark uncertain cash/receivables
explicitly, and never silently carry stale balances as verified current.

## Monthly net cash run rate

Monthly recurring take-home cash income − monthly cash spending and payment
commitments. Weekly × 52/12; every two weeks × 26/12; annual /12; monthly unchanged.
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

## Reviewed input and calculator

Write personal inputs/results only in PrivateStore/records/financial-summary/.
The plugin package contains procedures and synthetic tests, never live records.
Run from the plugin root:

```sh
python3 script/financial_summary.py --input /absolute/private/summary-input.json
```

Input schema version 1 has `as_of`, `period`, `currency`, `assumptions` (list), and
four nonempty entry lists: `assets`, `debts`, `income`, `outgoings`. Each entry has
unique `id`, nonnegative decimal-string `amount`, `category`, `source` and
`status` (`confirmed` or `estimated`). Income/outgoing entries also have
`frequency`: weekly, biweekly, monthly or yearly. Supply an explicit zero entry
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
assumptions before presenting the two headline metrics. Default answer: net
worth at the stated date; monthly cash in, monthly cash out and net cash run
rate for the stated observation window, followed by material uncertainty.
