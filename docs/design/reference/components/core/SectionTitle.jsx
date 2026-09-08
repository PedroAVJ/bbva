import React from 'react';
export function SectionTitle({ children, right }) {
  return (
    <div style={{display:'flex',alignItems:'baseline',justifyContent:'space-between'}}>
      <div style={{font:'var(--text-sechead)',letterSpacing:'0.08em',textTransform:'uppercase',color:'var(--text-secondary)',fontFamily:'var(--font-ui)'}}>{children}</div>
      {right ? <div style={{fontSize:11,color:'var(--text-tertiary)',fontVariantNumeric:'tabular-nums',fontFamily:'var(--font-ui)'}}>{right}</div> : null}
    </div>
  );
}
