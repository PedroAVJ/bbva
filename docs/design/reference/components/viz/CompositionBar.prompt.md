One bar = 100% of income; segments ordered by size, 2px gaps, 5px outer corners, in-segment % labels when ≥9% wide. Also exports `ZoomShade` (alias `zoomShade`) for flamegraph-zoomed detail bars.

```jsx
<CompositionBar segments={[
  {amount:9000,color:'var(--seg1)',label:'20%'},
  {amount:6000,color:'var(--seg3)',label:'DEBT 13%',darkLabel:true},
  {amount:15000,color:'var(--bbva-teal)',label:'YOURS 33%',darkLabel:true},
]} />
```

Rules: categorical colors follow the ENTITY, never the rank; the blue family cannot span more than 2–3 distinguishable slots. Detail bars subdivide one category via `ZoomShade(base,i,n)`.
