/** Detail-screen item row: shade dot, name, mo·day amounts (day emphasized), bold %. */
export interface ItemRowProps {
  name: string;
  /** Preformatted monthly amount, e.g. "4,500" */
  mo: string;
  /** Preformatted per-day amount, e.g. "150" */
  day: string;
  /** Preformatted percent of the category, e.g. "50%" */
  pct: string;
  /** Dot color — use ZoomShade(base,i,n) so dots mirror the zoomed bar */
  color: string;
  first?: boolean;
}
export declare function ItemRow(props: ItemRowProps): JSX.Element;
