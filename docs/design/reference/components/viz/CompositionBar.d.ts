/** Segmented 100%-composition bar; colors follow the entity, never the rank.
 * @startingPoint section="Data viz" subtitle="Income composition bar" viewport="700x120"
 */
export interface CompositionSegment {
  /** Relative size (used as flex-grow) */
  amount: number;
  /** CSS color — categorical color belongs to the ENTITY */
  color: string;
  /** In-segment label; only pass when the segment is ≥9% wide */
  label?: string;
  /** Dark navy label for light segments (seg3–seg5, teal) */
  darkLabel?: boolean;
}
export interface CompositionBarProps {
  segments: CompositionSegment[];
  /** Defaults to 26 */
  height?: number;
}
export declare function CompositionBar(props: CompositionBarProps): JSX.Element;
/** Flamegraph-zoom shade: color-mix(in oklab, base, white 0–50%) dark→light by index */
export declare function ZoomShade(base: string, i: number, n: number): string;
