/** Drillable legend row: color dot, label + faint sub, mo·day amount, bold %, chevron.
 * @startingPoint section="Rows" subtitle="Category legend row" viewport="700x160"
 */
export interface CategoryRowProps {
  name: string;
  /** Faint inline subtitle, e.g. "sample installments" */
  sub?: string;
  /** Preformatted amount, e.g. "9,000/mo · 300/day" */
  amount: string;
  /** Preformatted percent, e.g. "20%" */
  pct: string;
  /** Dot color — matches the segment color of the same entity */
  color: string;
  /** "Yours" treatment: teal 2px top rule, bold teal amounts */
  emphasized?: boolean;
  /** First row omits its top divider */
  first?: boolean;
  onClick?: () => void;
}
export declare function CategoryRow(props: CategoryRowProps): JSX.Element;
