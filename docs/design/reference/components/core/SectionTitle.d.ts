/** Uppercase 11px section kicker with optional right-aligned annotation.
 * @startingPoint section="Core" subtitle="Section header row" viewport="700x120"
 */
export interface SectionTitleProps {
  /** Section label — rendered uppercase, tracked out */
  children: React.ReactNode;
  /** Optional right-aligned faint annotation (e.g. an outlier note) */
  right?: React.ReactNode;
}
export declare function SectionTitle(props: SectionTitleProps): JSX.Element;
