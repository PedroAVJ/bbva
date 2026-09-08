import React from 'react';
import { RecoveryCard } from './RecoveryCard.jsx';
export function BalanceHero({ balance = 0, currency = 'MXN', dailyCredit = 0, spentToday = 0, typicalSlack = 0, kicker = 'Your balance', recovery = null, compact = false }) {
  const neg = balance < 0;
  const fmt = (v) => Math.abs(v).toLocaleString('en-US');
  const signed = (neg ? '−' : balance > 0 ? '+' : '') + fmt(balance);
  return (
    <div style={{background:'var(--surface-hero)',padding:'var(--bbva-pad-hero)'}}>
      <div style={{fontSize:12,fontWeight:600,letterSpacing:'0.06em',textTransform:'uppercase',color:'var(--text-kicker)',fontFamily:'var(--font-ui)'}}>{kicker}</div>
      <div style={{display:'flex',alignItems:'baseline',gap:10,marginTop:6}}>
        <div style={{fontFamily:'var(--font-display)',fontWeight:600,fontSize:compact?44:54,lineHeight:1,letterSpacing:'-0.025em',fontVariantNumeric:'tabular-nums',color:neg?'var(--color-negative)':'var(--color-positive)'}}>{signed}</div>
        <div style={{fontSize:14,color:'var(--text-on-hero-muted)',fontVariantNumeric:'tabular-nums',fontFamily:'var(--font-ui)'}}>{currency} · +{fmt(dailyCredit)} lands daily</div>
      </div>
      <div style={{fontSize:12,color:'var(--text-on-hero-muted)',marginTop:8,fontVariantNumeric:'tabular-nums',fontFamily:'var(--font-ui)'}}>spent today: {fmt(spentToday)} · typical slack: {fmt(typicalSlack)}/day</div>
      {recovery ? <div style={{marginTop:12}}><RecoveryCard>{recovery}</RecoveryCard></div> : null}
    </div>
  );
}
