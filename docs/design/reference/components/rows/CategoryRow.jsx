import React from 'react';
export function CategoryRow({ name, sub, amount, pct, color, emphasized = false, first = false, onClick }) {
  const [hover, setHover] = React.useState(false);
  return (
    <div onClick={onClick} onMouseEnter={()=>setHover(true)} onMouseLeave={()=>setHover(false)}
      style={{display:'flex',alignItems:'baseline',gap:8,padding:'7px 0',cursor:onClick?'pointer':'default',fontFamily:'var(--font-ui)',
        borderTop:first?'none':emphasized?'2px solid var(--color-positive)':'1px solid var(--border-hairline)'}}>
      <div style={{width:9,height:9,borderRadius:5,flex:'none',background:color,alignSelf:'center'}}></div>
      <div style={{fontSize:13,color:hover&&onClick?'var(--text-link)':'var(--text-body)',flex:1,fontWeight:emphasized?700:400}}>{name} {sub?<span style={{fontSize:11,color:'var(--text-tertiary)',fontWeight:400}}>{sub}</span>:null}</div>
      <div style={{fontSize:12,fontVariantNumeric:'tabular-nums',color:emphasized?'var(--color-positive)':'var(--text-secondary)',fontWeight:emphasized?600:400}}>{amount}</div>
      <div style={{fontSize:12,fontWeight:700,width:38,textAlign:'right',fontVariantNumeric:'tabular-nums',color:emphasized?'var(--color-positive)':'var(--text-body)'}}>{pct}</div>
      {onClick ? <div style={{fontSize:11,color:'var(--text-tertiary)',width:10,textAlign:'right'}}>›</div> : null}
    </div>
  );
}
