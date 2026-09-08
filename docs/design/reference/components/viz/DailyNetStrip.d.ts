/** One bar per day, teal above / coral below a zero hairline; square-root height scaling.
 * @startingPoint section="Data viz" subtitle="14-day daily-net strip" viewport="700x120"
 */
export interface DailyNetStripProps {
  /** Signed daily nets, oldest first (typically 14 values) */
  values: number[];
  /** Defaults to 56 */
  height?: number;
}
export declare function DailyNetStrip(props: DailyNetStripProps): JSX.Element;
