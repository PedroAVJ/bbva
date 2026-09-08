/** Navy-gradient hero: signed serif balance (coral/teal), drip line, spent-today line, optional recovery card.
 * @startingPoint section="Core" subtitle="Balance hero panel" viewport="470x260"
 */
export interface BalanceHeroProps {
  /** Signed balance; negative renders coral with − sign, positive teal with + */
  balance: number;
  /** Defaults to "MXN" */
  currency?: string;
  /** Daily drip amount ("+400 lands daily") */
  dailyCredit: number;
  spentToday?: number;
  typicalSlack?: number;
  /** Uppercase kicker; defaults to "Your balance" */
  kicker?: string;
  /** Recovery copy rendered in a RecoveryCard beneath the hero lines */
  recovery?: React.ReactNode;
  /** 44px hero number instead of 54px (detail heroes) */
  compact?: boolean;
}
export declare function BalanceHero(props: BalanceHeroProps): JSX.Element;
