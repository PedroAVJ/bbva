# BBVA Design System (Coronita)

Independent recreation of BBVA's public design language **Coronita** (BBVA Design, 2018 — behance.net/gallery/60505793) for Me's `bbva` plugin surfaces. Each plugin app wears its object's skin; this is BBVA's. The living reference implementation is the **BBVA** Claude Design project → `Allowance Mini.dc.html`.

## Color tokens — dark mode (primary)

The app is dark-first (the reference appearance). These are the shipped values:

| Token | Hex | Use |
| --- | --- | --- |
| `--bbva-navy` | `#051730` | Title bar, hero gradient start |
| `--bbva-bg` | `#0E1E33` | App surface |
| `--bbva-bg-deep` | `#0A1526` | Desktop backdrop |
| `--bbva-line` | `#20395B` | Hairlines, dividers |
| `--bbva-ink` | `#E8EEF5` | Primary text |
| `--bbva-ink-dim` | `#9FB3C8` | Secondary text |
| `--bbva-ink-faint` | `#66809B` | Tertiary text |
| `--bbva-coral` | `#F07285` | Negative balance, warnings |
| `--bbva-teal` | `#35B392` | Positive balance, "Yours" |
| `--seg1..seg5` | `#3A6EA8 #4E8FD0 #6FAEE3 #9CCAF0 #C7E1F8` | Category segments (dark-stepped) |
| hero gradient | `#051730 → #0A2E5C` | Hero panels |
| accent aqua | `#49A5E6` / `#5BBEFF` | Section kickers, back links |
| hero subtext | `#8FB8DA` | Muted text on navy |

Light-mode variants (earlier iterations) are preserved in this project's git history of `tokens.css`; dark is canonical.

## Typography

- **UI sans**: Benton Sans BBVA is proprietary; free stand-in **Libre Franklin** (same Franklin lineage). Weights 400–800.
- **Display numbers**: Coronita pairs a Tiempos-style serif for promotional figures; stand-in **Source Serif 4** semibold — used ONLY for hero numbers (balance, category per-day).
- Numerals: `font-variant-numeric: tabular-nums` in every data row.

## Spacing & shape

- 8px grid. Window frame radius 12px. Bars radius 5px (outer corners only), 2px gaps between segments.
- Hairline dividers between rows; 2px accent rule before totals.

## Motion

- Navigation is an iOS-style push: detail slides in from right over 340ms on `cubic-bezier(0.32, 0.72, 0.35, 1)`; home parallaxes back 28% beneath; incoming pane carries a left-edge shadow. Pop reverses; detail unmounts after transition.
- Fixed-height viewport (560px) with per-pane scrolling — chrome never moves, content scrolls.
- All transitions gated on `@media (prefers-reduced-motion: no-preference)`.

## Data-viz patterns

1. **Segmented composition bar** (home): one bar = 100% of income, segments ordered by size, in-segment % labels when ≥9% width, mirrored legend list below (dot-per-segment, same order). Categorical colors follow the ENTITY, never the rank — reordering categories never repaints them.
2. **Flamegraph zoom** (detail): the tapped category's segment becomes the whole bar, subdivided by its items, shaded via `color-mix(in oklab, <base>, white 0–50%)` dark→light by size. Caption keeps parent context ("X, zoomed · N% of income").
3. **Daily-net strip**: one bar per day, teal above / coral below a zero hairline, square-root height scaling so outliers don't flatten normal days. Direct annotation for outliers ("sample outlier: −1,200").
4. Palette rule: validate any categorical set with the dataviz validator; the blue family cannot span >2–3 distinguishable slots — prefer labels + ramp over more hues.

## Voice

- **English** (the reference language; adapt to the current product requirements).
- Terse labels, sentence case. Explanatory text 12px dim. Recovery guidance is imperative and concrete ("Even in 4 days spending nothing — or by the estimated recovery date").

## Interaction principle

Surfaces are **views, not dashboards**: state changes underneath; the only interaction is descending the aggregation hierarchy (progressive disclosure — flamegraph semantics). No filters, no date pickers, no config. Arbitrary questions go to agents.

## Taxonomy rules (settled 2026-08-14)

- Group by **the decision that governs the money**, not by surface resemblance or billing shape (no "subs" category).
- **Size promotes, size demotes**: a group earns a home segment at roughly ≥5% of income; below that it folds into Other and lives in the drill-down.
- Current categories: Health / Debt (ALL installment obligations incl. MSI) / AI / Housing & utilities / Other fixed / Yours.
