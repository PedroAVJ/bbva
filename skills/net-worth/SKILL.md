---
name: net-worth
description: Calculate or refresh financial net worth from the user's private BBVA balances, cash, collectible receivables, and outstanding debts at a stated date. Use for how much the user is worth, not monthly cash surplus.
---

# Financial net worth

Report **financial net worth at a stated timestamp**:

**Bank balances + cash held + supported collectible receivables − all outstanding debt.**

This workflow needs the balance sheet only. Do not require an income or expense
review for a net-worth-only request. For a monthly surplus or deficit, use
[$net-cash-run-rate](../net-cash-run-rate/SKILL.md).

## Resume the private review

Use the BBVA [private-store workflow](../bank/SKILL.md) to verify and read records.
When present, read `records/financial-summary/review-index.json` first; follow its
net-worth source pointer and the relevant methodology/decisions. Treat dated
snapshots as dated evidence, not live balances. Keep personal values, statements
and account identifiers outside the plugin repository.

Review account roles and the most recent supported balances at a consistent
cutoff. Include the full credit-card debt, future installments, family debt and
tax debt once. A statement's payment due is not necessarily its total outstanding
debt. Exclude computers, vehicles and other physical possessions from this
financial measure. Do not count an uncertain reimbursement as a collectible
receivable or count a settled receivable alongside the cash received.

When a current balance is missing, carry a clearly dated estimate only if its
basis is supported. Record unresolved components rather than silently making
them zero. Do not substitute monthly cash flow or paycheck totals for net worth.

## Calculate and retain

Use the [reviewed-input schema](../bank/references/financial-metrics.md#reviewed-input-and-calculator).
From the plugin root:

```bash
python3 script/financial_summary.py --metric net-worth --input /absolute/private/net-worth-input.json
```

This mode requires `as_of`, `currency`, `assumptions`, `assets` and `debts`;
`period`, `income` and `outgoings` are not required. The calculator checks and sums
reviewed entries; it does not discover or reconcile accounts automatically.

Lead with the amount and timestamp, then the material estimates or missing
coverage. Save reviewed inputs, output and source references through the private
store import workflow, retaining the prior dated version. Update the review
index's net-worth pointer without changing its independent run-rate pointer.
