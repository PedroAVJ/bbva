import React from 'react';
export function CompositionBar({ segments = [], height = 26 }) {
  const n = segments.length;
  return (
    <div style={{display:'flex',gap:'var(--bbva-seg-gap)',height}}>
      {segments.map((s, i) => (
        <div key={i} style={{flexGrow:s.amount,flexBasis:0,minWidth:0,height,background:s.color,borderRadius:i===0?'5px 0 0 5px':i===n-1?'0 5px 5px 0':'0'}}>
          {s.label ? <div style={{fontSize:10,fontWeight:700,fontFamily:'var(--font-ui)',color:s.darkLabel?'var(--bbva-seg-label-dark)':'#FFFFFF',display:'flex',alignItems:'center',justifyContent:'center',height,overflow:'hidden',whiteSpace:'nowrap'}}>{s.label}</div> : null}
        </div>
      ))}
    </div>
  );
}
export function ZoomShade(base, i, n) {
  const mix = n <= 1 ? 0 : Math.round(50 * i / (n - 1));
  return `color-mix(in oklab, ${base}, white ${mix}%)`;
}
export const zoomShade = ZoomShade;
