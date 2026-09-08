Ledger transaction row: category dot, two-line description + faint meta ("Jan 14 · Food & daily · for Me"), right-aligned signed tabular amount (teal when income, ink when expense, true minus −).

```jsx
<TransactionRow desc="Rent" meta="Jan 1 · Housing & utilities" amount="−7,500" color="var(--seg4)" recurring first />
<TransactionRow desc="Salary" meta="Jan 1 · for Me" amount="+45,000" color="var(--bbva-teal)" positive recurring />
```

Not clickable — drill-down happens at the category level, never per transaction.
