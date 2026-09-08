The home-screen hero: navy gradient panel, aqua kicker, 54px Source Serif signed balance (coral when behind, teal when ahead), drip + spent-today lines, optional recovery card.

```jsx
<BalanceHero balance={-1200} dailyCredit={400} spentToday={180} typicalSlack={40}
  recovery={<><span style={{color:'var(--color-negative)',fontWeight:700}}>1,200 behind.</span> Even in <strong style={{color:'var(--text-body)'}}>3 days</strong> spending nothing…</>} />
```

One number answers "can I spend right now". Gradient #051730→#0A2E5C; padding 22/24/18.
