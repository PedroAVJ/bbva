Last-14-days daily-net strip: one bar per day, teal above / coral below a zero hairline, square-root height scaling so outliers don't flatten normal days.

```jsx
<DailyNetStrip values={[40,90,-60,20,150,-1200,130,40,-180,400,-80,55,110,125]} />
```

Annotate outliers directly in the SectionTitle right slot ("sample outlier: −1,200") — never with tooltips.
