import React from 'react';
export function TransactionRow({ desc, meta, amount, positive = false, color, recurring = false, first = false }) {
  return (
    <div style={{display:'flex',alignItems:'center',gap:8,padding:'8px 0',fontFamily:'var(--font-ui)',borderTop:first?'none':'1px solid var(--border-hairline)'}}>
      <div style={{width:9,height:9,borderRadius:5,flex:'none',background:color||'var(--bbva-ink-faint)'}}></div>
      <div style={{flex:1,minWidth:0}}>
        <div style={{fontSize:13,color:'var(--text-body)',whiteSpace:'nowrap',overflow:'hidden',textOverflow:'ellipsis'}}>{desc}</div>
        <div style={{fontSize:11,color:'var(--text-tertiary)',marginTop:1}}>{meta}{recurring?<span> · recurring</span>:null}</div>
      </div>
      <div style={{fontSize:13,fontWeight:600,fontVariantNumeric:'tabular-nums',color:positive?'var(--color-positive)':'var(--text-body)'}}>{amount}</div>
    </div>
  );
}
