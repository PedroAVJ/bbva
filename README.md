# Bancomer

Bancomer is a local-first income and expense ledger. The native iPhone app
under `ios/` uses Apple's Liquid Glass for system navigation and primary
actions, while keeping financial content on opaque surfaces. Reusable web
reference components live under `docs/design/reference/ui_kits/pwa/`.

The original macOS app under `Sources/BBVA` is deprecated. Its code and private
SQLite tooling remain here for history, migration, and statement reconciliation,
but new product work targets iOS and the PWA.

## First-release scope

Both current clients focus on the same small accounting loop:

- Income, expenses, and net for the current month
- Expense composition by category
- Recurring versus one-time spending
- Recent transactions and category drill-down
- Manual transaction entry

Transaction data remains on the device. The apps do not connect to BBVA, Belvo,
or another bank-data intermediary.

## Native iOS app

The Xcode project is generated from `ios/project.yml` and targets iOS 26 or
newer. Generate and validate it with:

    cd ios
    xcodegen generate
    xcodebuild -project Bancomer.xcodeproj -scheme Bancomer \\
      -destination 'generic/platform=iOS Simulator' \\
      CODE_SIGNING_ALLOWED=NO build

The ledger is stored as an atomically written JSON document in Application
Support with complete file protection. Operational telemetry is privacy-safe:
it records fixed lifecycle/action names only, never amounts, descriptions,
categories, people, account identifiers, or device identity.

## Design source

The reusable design handoff is checked in under `docs/design/reference/`.
It contains synthetic examples and omits private hosted-project metadata.
The original design inputs remain under `design/`.

## Deprecated macOS app and private store

The macOS package reads its historical dashboard from a private SQLite database
outside Git at:

    ~/Library/Application Support/com.pedroavj.bbva/PrivateStore/dashboard.sqlite3

Personal statements, transactions, balances, account identifiers, and derived
records remain outside the repository. The guarded legacy tooling can still
verify that store:

    python3 script/bank_store.py verify
    python3 script/bank_store.py list

Legacy validation remains available with:

    swift test --jobs 1
    python3 -m unittest discover -s Tests/BankStoreCLITests
    ./script/build_and_run.sh --package

## Agent financial summary

The BBVA plugin offers separate [financial net worth](skills/net-worth/SKILL.md)
and [net cash run rate](skills/net-cash-run-rate/SKILL.md) skills. Either can run
independently, with private review pointers preserving the latest methodology,
item-level estimates and corrections for the next iteration. See
[the financial metrics contract](skills/bank/references/financial-metrics.md)
for repayment inclusion, balance reconciliation and the reviewed-input CLI.
This plugin workflow is independent of the app ledger and its net-income view.
