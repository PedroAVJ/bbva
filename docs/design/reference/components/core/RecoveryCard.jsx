import React from 'react';
export function RecoveryCard({ children }) {
  return (
    <div style={{background:'var(--recovery-bg)',border:'1px solid var(--recovery-border)',borderRadius:'var(--bbva-radius-card)',padding:'10px 12px',fontSize:12,lineHeight:1.55,color:'var(--text-secondary)',fontFamily:'var(--font-ui)'}}>{children}</div>
  );
}
