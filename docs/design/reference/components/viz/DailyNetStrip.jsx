import React from 'react';
export function DailyNetStrip({ values = [], height = 56 }) {
  const half = Math.floor(height / 2);
  const maxAbs = values.reduce((m, v) => Math.max(m, Math.abs(v)), 1);
  return (
    <div style={{display:'flex',alignItems:'stretch',gap:3,height}}>
      {values.map((v, i) => {
        const h = Math.max(3, Math.round((half - 2) * Math.sqrt(Math.abs(v) / maxAbs)));
        const pos = v >= 0;
        return (
          <div key={i} style={{flex:1,position:'relative',height}}>
            <div style={{position:'absolute',left:-2,right:-2,top:half,height:1,background:'var(--border-hairline)'}}></div>
            <div style={{position:'absolute',left:0,right:0,borderRadius:2,top:pos?half-h:half+1,height:h,background:pos?'var(--color-positive)':'var(--color-negative)'}}></div>
          </div>
        );
      })}
    </div>
  );
}
