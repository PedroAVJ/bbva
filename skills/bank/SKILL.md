---
name: bank
description: Read, verify, import, or maintain the user's BBVA-owned records through the BBVA plugin's private local store. Use for BBVA statements, transactions, balances, account roles and identifiers, deposit cadence, bank-linked insurance, merchant categorization, recurring commitments, financial net worth, monthly net cash run rate, and derived spending data.
---

# BBVA

Treat the `PedroAVJ/bbva` GitHub repository as canonical plugin source.
For source work, use a task-specific clone and never edit an installed cache.
Keep personal bank data out of that repository and out of other corpora. The
private store defaults to
`~/Library/Application Support/com.pedroavj.bbva/PrivateStore`.

## Default financial summary

For net worth, net run rate, monthly cash surplus/shortfall, or a general personal
financial summary, read [the financial metrics contract](references/financial-metrics.md).
Report **financial net worth** and **monthly net cash run rate** by those names.
Cash run rate includes card installments, parents/family repayments and tax/loan
principal payments. Never silently replace it with accrual income, depreciation,
net-worth change or the number of paychecks received. Use balances to constrain
missing-statement estimates, and count each obligation once.

## Read and verify

Run from the plugin root:

```bash
python3 script/bank_store.py verify
python3 script/bank_store.py list
python3 script/bank_store.py read --record records/path/to/text-record.md
```

List paths before reading when the requested record is ambiguous. Do not print
unrequested identifiers, balances, raw transactions, or credentials.

## Import

Import only from an identified source boundary and record repository provenance:

```bash
python3 script/bank_store.py import \
  --source /absolute/source/path \
  --destination records/category \
  --provenance-root /absolute/source/repository \
  --repository owner/repository \
  --revision GIT_COMMIT
```

Verify after every import. Remove the source only after the imported files pass
checksum verification and any inbound references have been updated.

## Ownership boundary

- Store stable schemas, procedures, code, and tests in the plugin repository.
- Store personal statements, account data, transaction-derived outputs, bank
  product records, and changing values only in the private store.
- Keep SAT, RFC, CFDI, tax, career narrative, medical, and relationship records
  with their own source owners even when a bank transaction is supporting evidence.
- Do not open the native app unless the requested task needs its UI.
