---
name: net-cash-run-rate
description: Calculate, rank, or iterate on the user's normalized monthly cash surplus or deficit from recurring take-home income, bills, debt payments, reserves, and recurring variable spending in private BBVA records. Use for income run rate versus expense run rate, not balance-sheet net worth.
---

# Monthly net cash run rate

Report **monthly net cash run rate** (also called **normalized monthly cash flow**):

**Monthly take-home income run rate − monthly spending and payment run rate.**

Both sides are cash per month. Positive means the usual pattern adds cash;
negative means it consumes savings or adds debt. If the user says “net income”
in this context, answer this cash question without turning terminology into a
detour. Debt principal belongs in this measure. A run-rate-only request does not
require refreshing assets, outstanding balances or net worth.

## Resume the private review

Use the BBVA [private-store workflow](../bank/SKILL.md). When present, start at
`records/financial-summary/review-index.json`, follow its current run-rate input,
ranked report, methodology and correction decisions, and check the source dates.
An older category summary or bank merchant label does not override a later
item-level correction supported by a receipt or explicit user instruction.
Keep personal values and evidence in the private store, never in plugin source.

Preserve the user's established scope, quantities, prices and frequency choices
unless newer evidence or instructions change them. Record what changed and why;
do not silently rebuild the budget from old generic category assumptions.

## Build the monthly baseline

- Include bills, subscriptions, existing debt installments and principal
  repayments, current taxes, recurring variable purchases, and reserves for
  predictable irregular costs. Count an obligation once. Bank-to-card payments
  are not additional expenses when underlying purchases are already included.
- Normalize weekly ×52/12, every two weeks ×26/12, every four weeks ×13/12,
  and annual bills /12. Financed purchases contribute their actual installments,
  not their full price or depreciation. Use current prices; show trial endings,
  scheduled increases and debt end dates separately.
- Use a disclosed completed billing cycle or other supported averaging window
  for variable spending. Include everyday food, transport and household items
  as estimates even when personal allocation or replenishment cadence is
  uncertain. Flag gross shared portions and multipacks instead of dropping them
  from the working total. Never invent a 50/50 split or reimbursement.
- Exclude costs known to belong to other people unless the user explicitly
  chooses to fund them. Existing family-debt repayments remain cash obligations.
- Predictable occasional purchases need an allowance or sinking-fund reserve.
  A genuine exceptional one-off stays separately visible. Do not both reserve
  for an item and add the same purchase again, or invent a monthly cadence for
  an exceptional purchase.
- A known but unquantified cost is not zero. State what is absent from the
  quantified estimate. Do not substitute an incomplete subtotal for the full
  working estimate or present estimates as verified exact personal consumption.

When ranking, show individual services, recurring products and obligations,
largest monthly amount first. Combine repeat spending when it represents one
useful expense, such as DiDi rides or the same vendor's API credits. Keep
unrelated subscriptions, products and appointments separate; broad categories
are not the default ranking. Show food and household estimates in the ranking,
not only in an excluded-items appendix.

## Calculate, explain and retain

Use the [reviewed-input schema](../bank/references/financial-metrics.md#reviewed-input-and-calculator).
From the plugin root:

```bash
python3 script/financial_summary.py --metric net-cash-run-rate --input /absolute/private/run-rate-input.json
```

This mode requires `as_of`, `period`, `currency`, `assumptions`, `income` and
`outgoings`; it does not require `assets` or `debts`. Preserve item labels and
source/status on inputs. Monthly estimates can use `frequency: monthly` after
their normalization or averaging method is disclosed. The output includes
monthly totals and ranked outgoings, not automated expense classification.

Lead with monthly income, monthly expenses and the positive/negative difference.
Describe the material uncertainty and any temporary debt burden. A hypothetical
debt-free baseline is a scenario, not a claim that all payments end soon.

Save dated inputs, results, item-level reports and correction evidence through
the private store import workflow. Retain superseded snapshots and update the
review index's run-rate pointer without changing its net-worth pointer. Preserve
settlement uncertainty and the reason for each changed inclusion or amount so
the next review can iterate rather than repeat the investigation.
