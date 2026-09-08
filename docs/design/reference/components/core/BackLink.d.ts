/** Aqua "‹ Back" pop-navigation link used at the top of detail heroes. */
export interface BackLinkProps {
  onClick?: () => void;
  /** Defaults to "Back" */
  label?: string;
}
export declare function BackLink(props: BackLinkProps): JSX.Element;
