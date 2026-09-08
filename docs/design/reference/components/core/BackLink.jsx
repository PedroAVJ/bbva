import React from 'react';
export function BackLink({ onClick, label = 'Back' }) {
  const [hover, setHover] = React.useState(false);
  return (
    <div onClick={onClick} onMouseEnter={()=>setHover(true)} onMouseLeave={()=>setHover(false)} style={{display:'flex',alignItems:'center',gap:6,cursor:'pointer',fontSize:13,fontWeight:600,fontFamily:'var(--font-ui)',color:hover?'var(--bbva-accent-aqua-hover)':'var(--bbva-accent-aqua)'}}>‹ {label}</div>
  );
}
