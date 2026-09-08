import React from 'react';
export function ItemRow({ name, mo, day, pct, color, first = false }) {
  return (
    <div style={{display:'flex',alignItems:'baseline',gap:8,padding:'8px 0',fontFamily:'var(--font-ui)',borderTop:first?'none':'1px solid var(--border-hairline)'}}>
      <div style={{width:9,height:9,borderRadius:5,flex:'none',background:color,alignSelf:'center'}}></div>
      <div style={{fontSize:13,color:'var(--text-body)',flex:1}}>{name}</div>
      <div style={{fontSize:12,fontVariantNumeric:'tabular-nums',color:'var(--text-secondary)'}}>{mo}/mo · <span style={{fontWeight:600,color:'var(--text-body)'}}>{day}/day</span></div>
      <div style={{fontSize:12,fontWeight:700,width:38,textAlign:'right',fontVariantNumeric:'tabular-nums',color:'var(--text-body)'}}>{pct}</div>
    </div>
  );
}
