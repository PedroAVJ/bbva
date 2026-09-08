# Bancomer Design System

An independent personal-finance design language, restored from the Git-backed **BBVA Coronita** recreation at [github.com/PedroAVJ/bbva](https://github.com/PedroAVJ/bbva) (see `design/DESIGN_SYSTEM.md`, `design/tokens.css`, `design/SPEC.md`, `design/Allowance Mini.dc.html`, and `Sources/BBVA/` SwiftUI views — explore the repo for deeper context when designing). It is an independent recreation of BBVA's public 2018 design language "Coronita" using free stand-in fonts; this is not an official BBVA product, and service marks remain the property of their owner.

**Products** (first release: a simple income-and-expense ledger — manual, offline, on-device; income & expenses, recurring vs one-time, progressive disclosure):
- **iOS app** (`ui_kits/ios/`) — native SwiftUI target; real Apple Liquid Glass used *judiciously* for navigation and actions only (the floating Add-transaction pill); financial content stays opaque and readable.
- **PWA** (`ui_kits/pwa/`) — standalone installable web app; same brand, opaque navy action and form sheet, does NOT imitate native Liquid Glass.
- The macOS app is **deprecated** (the source mockup's traffic-light title bar is historical).

**Core principle — views, not dashboards.** State changes underneath; the only interactions are descending the aggregation hierarchy (category drill-down, flamegraph semantics) and adding a transaction. No filters, no date pickers, no configuration UI, no analytics controls. Calm, personal, editorial. Synthetic data only — never request or display real financial records, balances, or credentials.

## Content fundamentals

- **English**, terse labels, **sentence case** ("Where the income goes", "Last 14 days · daily net"). Section headers render as small tracked caps via styling, but are written in sentence case.
- **Second person**: "Your balance", "Yours" (the user's discretionary money).
- Explanatory text is 12px dim; recovery guidance is **imperative and concrete**: "1,200 behind. Even in 3 days spending nothing — or by Feb 14 at typical pace. A cheap week beats a perfect day."
- Middle dots (·) join figures: "9,000/mo · 300/day". True minus sign (−, U+2212), en-US thousands separators, whole numbers only.
- Faint inline subtitles annotate categories ("sample installments"). Outliers are annotated directly, never in tooltips ("sample outlier: −1,200").
- **No emoji.** No exclamation marks. Calm, factual, slightly aphoristic.

## Visual foundations

- **Dark-first**: dark mode is canonical (the reference appearance). Navy surface stack: titlebar/hero `#051730`, app surface `#0E1E33`, backdrop `#0A1526`, hairlines `#20395B`. Light-mode variants live only in the source repo's git history.
- **Type**: UI sans **Libre Franklin** (stand-in for proprietary Benton Sans BBVA, weights 400–800); display serif **Source Serif 4** semibold used ONLY for hero numbers (54px balance, 44px detail per-day). `tabular-nums` in every data row.
- **Color**: three-step ink scale (`#E8EEF5` / `#9FB3C8` / `#66809B`); teal `#35B392` = positive/Yours, coral `#F07285` = negative; aqua `#49A5E6` (hover `#5BBEFF`) for kickers and back links; categorical blues `seg1–seg5` for composition segments — **color follows the entity, never the rank**; the blue family cannot span more than 2–3 distinguishable slots.
- **Backgrounds**: flat navy or the hero gradient `#051730 → #0A2E5C`. No imagery, no textures, no illustrations.
- **Spacing/shape**: 8px grid; frame radius 12px; bar radius 5px (outer corners only) with 2px segment gaps; cards 8px. Hero padding 22/24/18; sections 16–18px.
- **Borders/rules**: 1px hairline dividers between rows; a 2px teal accent rule before totals (the "Yours" row). The only "card" is the coral recovery card: `rgba(240,114,133,.1)` fill, `.35` border, radius 8.
- **Shadows**: window/PWA frame `0 18px 50px rgba(0,0,0,.55), 0 2px 8px rgba(0,0,0,.4)`; pushed detail pane carries a left-edge shadow `-12px 0 28px rgba(0,0,0,.5)`. No inner shadows.
- **Motion**: one signature move — iOS-style push, 340ms `cubic-bezier(0.32,0.72,0.35,1)`, home parallaxes back 28%, pop reverses; gated on `prefers-reduced-motion`. Chrome never moves; content scrolls per pane in a fixed-height viewport.
- **Hover**: links/labels tint to seg3 `#6FAEE3` → seg4; aqua brightens to `#5BBEFF`. No press-shrink effects.
- **Transparency/blur**: iOS only, and only for navigation/action chrome (Liquid Glass). Financial content is always opaque. The PWA uses no blur at all.
- **Data viz**: segmented 100%-composition bar with in-segment % labels when ≥9% wide; flamegraph zoom shades via `color-mix(in oklab, base, white 0–50%)` dark→light by size; daily-net strip with square-root height scaling.

## Iconography

The source defines almost no iconography — deliberately. Text characters serve as icons: `›` (drill-in chevron), `‹ Back`, `·` (joiner), `−`/`+` signs, 9px color dots as category markers. SwiftUI uses SF Symbols' `chevron.right` only. **No icon font, no SVG icon set, no emoji.** Don't introduce icon libraries; if an icon is unavoidable on iOS, use SF Symbols at hairline weights.

**No logo**: the repo's app icon is official BBVA México App Store artwork (trademark; see repo `ICON-SOURCES.md`) and was deliberately **not** copied. Render the brand name "Bancomer" in plain type (Source Serif 4 semibold works as a wordmark) wherever a mark would go.

**App icon** (production): an original, trademark-safe identifier — a single Source Serif 4 semibold “B” on the hero gradient. Full-bleed square, no transparency, no baked corner mask, no gloss/blur/glass, no other text or symbols. It is an app identifier, not a logo. Source `assets/app-icon.svg`; production raster `assets/app-icon-1024.png`; specimen `guidelines/app-icon.html`.

## Index

- `styles.css` → `tokens/` (colors, typography, spacing, motion, fonts) — fonts in `assets/fonts/` (Libre Franklin + Source Serif 4 variable TTFs, copied from the repo); app icon in `assets/`.
- `guidelines/` — specimen cards: surfaces, ink, semantic, segments, hero gradient, sans, serif, numerals, shape, rules, motion, voice, glass policy, app icon.
- `components/core/` — **BalanceHero**, **RecoveryCard**, **SectionTitle**, **BackLink**.
- `components/viz/` — **CompositionBar** (+ `zoomShade`), **DailyNetStrip**.
- `components/rows/` — **CategoryRow**, **ItemRow**, **TransactionRow**.
- `ui_kits/ios/` — iPhone-framed interactive ledger: home → category-detail push + add-transaction sheet (glass Add pill).
- `ui_kits/pwa/` — installable web-app shell around the same panes (opaque navy Add action, no glass).
- `ui_kits/screens.jsx`, `ui_kits/shared-data.js` — shared ledger panes, add sheet + synthetic transaction sample.

**Intentional additions**: `ItemRow`, `BackLink`, `RecoveryCard` are extracted from inline markup in the source mockup (`.itemrow`, `.backrow`, `.recov`) rather than named source components — same values, promoted to primitives for reuse. `TransactionRow` is new for the ledger release (no source counterpart; follows the row grammar exactly). `BalanceHero`/`RecoveryCard` and the daily-drip/allowance framing (daily-net strip, recovery guidance, "Your balance", typical slack) belong to the preserved allowance design and are NOT used on first-release ledger screens. The Roadmap/projection screen from SPEC.md is **not** built (not yet mocked in the source; do not invent it).
