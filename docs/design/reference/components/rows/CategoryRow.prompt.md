Category legend row under the composition bar; tapping descends the hierarchy (the system's only interaction). Dot color equals the entity's segment color.

```jsx
<CategoryRow name="Health" amount="9,000/mo · 300/day" pct="20%" color="var(--seg1)" onClick={open} first />
<CategoryRow name="Yours" amount="15,000/mo · 500/day" pct="33%" color="var(--bbva-teal)" emphasized onClick={open} />
```

Hairline top dividers between rows; the "Yours" row takes a 2px teal accent rule instead. Hover tints the label to seg3 blue.
