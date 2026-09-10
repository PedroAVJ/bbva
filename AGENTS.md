# Repository guidance

- This repository is the canonical source for the user's BBVA plugin and native
  BBVA macOS app.
- Keep credentials, raw SMS bodies, transactions, account identifiers, and
  changing personal balances out of Git.
- data/seed.json is an explicit sample fixture. Never relabel it as live.
- The BBVA plugin owns bank statements, transactions, balances, account meaning,
  bank-linked products, reconciled records, and derived spending data.
- Keep personal records in the private store at
  `~/Library/Application Support/com.pedroavj.bbva/PrivateStore`; the Git package
  owns only stable procedures, schemas, code, and tests.
- Preserve DashboardSnapshot and DashboardDataSource when replacing the seed
  loader with a private daemon or SQLite store.
- Build with one worker by default to bound memory usage. Run Swift and private-store tests plus
  the native app build before a release. Perform a real-window acceptance check
  only when UI behavior changes or a release is requested.

## Design reference

- Maintain `design/DESIGN_SYSTEM.md`, `design/tokens.css`, `design/SPEC.md`,
  and `design/Allowance Mini.dc.html` as the source design inputs.
- Reusable reference components and synthetic examples live under
  `docs/design/reference/`. Keep private hosted-project IDs, operator links,
  account information, and real financial records out of the reference.
