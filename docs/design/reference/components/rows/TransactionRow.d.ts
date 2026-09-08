/** Ledger transaction row: category dot, description + faint meta line, signed tabular amount. */
export interface TransactionRowProps {
  desc: string;
  /** Faint meta line, e.g. "Jan 14 · Food & daily · for Me" */
  meta: React.ReactNode;
  /** Preformatted signed amount, e.g. "−1,850" or "+45,000" */
  amount: string;
  /** Income rows render the amount teal */
  positive?: boolean;
  /** Category dot color (teal for income) */
  color?: string;
  /** Appends " · recurring" to the meta line */
  recurring?: boolean;
  first?: boolean;
}
export declare function TransactionRow(props: TransactionRowProps): JSX.Element;
