# Allowance design reference

The allowance view is a local daily-finance interface. Its running balance
provides context for discretionary spending. The maintained native ledger is
under `ios/`; this document describes the reusable allowance design.

## Accounting model

- Add the configured daily allowance and subtract discretionary transactions.
  The running balance carries forward rather than resetting each month.
- Daily allowance derives from configured income, recurring commitments, and
  a user-selected savings allocation. Production inputs belong in the private
  store; `data/seed.json` contains synthetic examples only.
- Recovery estimates derive from the balance, allowance, and observed spending.
  Label assumptions and never present a projection as a financial guarantee.
- Any statement or SMS ingestion requires separately configured, authorized
  private sources. This public specification embeds no account setup or history.

## Views

1. Home: signed balance, daily allowance, spent-today value, recovery estimate,
   daily-net strip, and a category composition bar with progressive disclosure.
2. Category detail: category total, proportional items, and a short explanatory
   note grounded in the configured data.
3. Future projections may use explicit commitment schedules from the private
   store. Do not invent obligations, due dates, or expected changes.

## Example data

Use `data/seed.json` for fixtures. Its generic categories and values exercise the
UI and do not describe a person. Keep design references and test data synthetic.
