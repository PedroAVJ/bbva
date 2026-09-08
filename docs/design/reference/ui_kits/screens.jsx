const DS = window.BancomerDesignSystem_930545;
const { SectionTitle, CompositionBar, CategoryRow, BackLink, ZoomShade } = DS;
const zoomShade = ZoomShade || ((base,i,n)=>`color-mix(in oklab, ${base}, white ${n<=1?0:Math.round(50*i/(n-1))}%)`);
// Stale-bundle fallback for the newest component
const TxRow = DS.TransactionRow || function TxRowFallback({ desc, meta, amount, positive, color, recurring, first }) {
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
};

const D0 = window.BANCOMER_DATA;
const fmt = (v) => Math.round(v).toLocaleString('en-US');
const catOf = (id) => D0.cats.find(c=>c.id===id);

function derive(txs) {
  let income=0, expense=0, recurring=0, oneTime=0;
  const byCat = {};
  D0.cats.forEach(c=>{ byCat[c.id]={ total:0, rec:0, one:0, txs:[] }; });
  txs.forEach(t=>{
    if (t.kind==='income') { income+=t.amount; return; }
    expense+=t.amount;
    if (t.recurring) recurring+=t.amount; else oneTime+=t.amount;
    const b = byCat[t.catId]; if (b){ b.total+=t.amount; b.txs.push(t); if(t.recurring)b.rec+=t.amount; else b.one+=t.amount; }
  });
  return { income, expense, net:income-expense, recurring, oneTime, byCat };
}

const kickerStyle = {fontSize:12,fontWeight:600,letterSpacing:'0.06em',textTransform:'uppercase',color:'var(--text-kicker)'};
const heroSub = {fontSize:12,color:'var(--text-on-hero-muted)',fontVariantNumeric:'tabular-nums'};

function HomePane({ txs, onOpen }) {
  const d = derive(txs);
  const neg = d.net < 0;
  const sorted = D0.cats.map(c=>({...c, total:d.byCat[c.id].total, n:d.byCat[c.id].txs.length})).filter(c=>c.total>0).sort((a,b)=>b.total-a.total);
  const pctE = (v) => Math.round(100*v/(d.expense||1));
  return (
    <div>
      <div style={{background:'var(--surface-hero)',padding:'var(--bbva-pad-hero)'}}>
        <div style={kickerStyle}>Net this month</div>
        <div style={{display:'flex',alignItems:'baseline',gap:10,marginTop:6}}>
          <div style={{fontFamily:'var(--font-display)',fontWeight:600,fontSize:54,lineHeight:1,letterSpacing:'-0.025em',fontVariantNumeric:'tabular-nums',color:neg?'var(--color-negative)':'var(--color-positive)'}}>{(neg?'−':'+')+fmt(Math.abs(d.net))}</div>
          <div style={{...heroSub,fontSize:14}}>{D0.currency} · {D0.rangeLabel}</div>
        </div>
        <div style={{display:'flex',gap:28,marginTop:14}}>
          <div><div style={{fontSize:11,fontWeight:700,letterSpacing:'0.06em',textTransform:'uppercase',color:'var(--text-on-hero-muted)'}}>Income</div><div style={{fontSize:17,fontWeight:600,color:'var(--color-positive)',fontVariantNumeric:'tabular-nums',marginTop:2}}>+{fmt(d.income)}</div></div>
          <div><div style={{fontSize:11,fontWeight:700,letterSpacing:'0.06em',textTransform:'uppercase',color:'var(--text-on-hero-muted)'}}>Expenses</div><div style={{fontSize:17,fontWeight:600,color:'var(--color-negative)',fontVariantNumeric:'tabular-nums',marginTop:2}}>−{fmt(d.expense)}</div></div>
        </div>
      </div>

      <div style={{padding:'16px 18px 4px'}}>
        <div style={{marginBottom:10}}><SectionTitle right={<span style={{fontSize:13,fontWeight:700,color:'var(--text-body)',fontVariantNumeric:'tabular-nums'}}>{fmt(d.expense)}</span>}>Where expenses go</SectionTitle></div>
        <CompositionBar segments={sorted.map(c=>({amount:c.total,color:c.color,label:pctE(c.total)>=9?pctE(c.total)+'%':'',darkLabel:c.dark}))} />
        <div style={{marginTop:12}}>
          {sorted.map((c,i)=>(
            <CategoryRow key={c.id} name={c.name} sub={c.n+' tx'} amount={fmt(c.total)} pct={pctE(c.total)+'%'} color={c.color} first={i===0} onClick={()=>onOpen(c.id)} />
          ))}
        </div>
      </div>

      <div style={{padding:'14px 18px 4px'}}>
        <div style={{marginBottom:10}}><SectionTitle>Recurring vs one-time</SectionTitle></div>
        <CompositionBar height={18} segments={[
          {amount:d.recurring,color:'var(--seg1)',label:pctE(d.recurring)>=9?'RECURRING '+pctE(d.recurring)+'%':''},
          {amount:d.oneTime,color:'var(--seg3)',label:pctE(d.oneTime)>=9?'ONE-TIME '+pctE(d.oneTime)+'%':'',darkLabel:true}
        ]} />
        <div style={{marginTop:10}}>
          <CategoryRow name="Recurring" sub="repeats monthly" amount={fmt(d.recurring)} pct={pctE(d.recurring)+'%'} color="var(--seg1)" first />
          <CategoryRow name="One-time" amount={fmt(d.oneTime)} pct={pctE(d.oneTime)+'%'} color="var(--seg3)" />
        </div>
      </div>

      <div style={{padding:'14px 18px 18px'}}>
        <div style={{marginBottom:4}}><SectionTitle right={txs.length+' this month'}>Recent</SectionTitle></div>
        {txs.slice(0,7).map((t,i)=>{
          const c = t.kind==='income'?null:catOf(t.catId);
          return <TxRow key={t.date+t.desc+i} desc={t.desc} meta={t.date+(c?' · '+c.name:'')+(t.forWho&&t.forWho!=='Me'?' · for '+t.forWho:'')} amount={(t.kind==='income'?'+':'−')+fmt(t.amount)} positive={t.kind==='income'} color={c?c.color:'var(--bbva-teal)'} recurring={t.recurring} first={i===0} />;
        })}
      </div>
    </div>
  );
}

function DetailPane({ catId, txs, onBack }) {
  const d = derive(txs);
  const cat = catOf(catId);
  const b = d.byCat[catId];
  const pct = Math.round(100*b.total/(d.expense||1));
  const shown = b.txs;
  const n = shown.length;
  return (
    <div>
      <div style={{background:'var(--surface-hero)',padding:'var(--bbva-pad-hero)'}}>
        <BackLink onClick={onBack} />
        <div style={{display:'flex',alignItems:'center',gap:8,marginTop:14}}>
          <div style={{width:11,height:11,borderRadius:6,background:cat.color}}></div>
          <div style={kickerStyle}>{cat.name}</div>
        </div>
        <div style={{display:'flex',alignItems:'baseline',gap:10,marginTop:6}}>
          <div style={{fontFamily:'var(--font-display)',fontWeight:600,fontSize:44,lineHeight:1,color:'#fff',fontVariantNumeric:'tabular-nums'}}>−{fmt(b.total)}</div>
          <div style={{...heroSub,fontSize:14}}>{D0.currency} this month · {pct}% of expenses</div>
        </div>
        <div style={{...heroSub,marginTop:8}}>recurring {fmt(b.rec)} · one-time {fmt(b.one)} · {n} transaction{n===1?'':'s'}</div>
      </div>
      <div style={{padding:'16px 18px 16px'}}>
        <CompositionBar segments={shown.map((t,i)=>{
          const p = Math.round(100*t.amount/(b.total||1));
          return {amount:t.amount,color:zoomShade(cat.color,i,n),label:p>=9?p+'%':'',darkLabel:true};
        })} />
        <div style={{fontSize:11,color:'var(--text-tertiary)',fontVariantNumeric:'tabular-nums',margin:'6px 0 8px'}}>{cat.name}, zoomed · {pct}% of expenses this month</div>
        {shown.map((t,i)=>(
          <TxRow key={t.date+t.desc+i} desc={t.desc} meta={t.date+(t.forWho&&t.forWho!=='Me'?' · for '+t.forWho:'')} amount={'−'+fmt(t.amount)} color={zoomShade(cat.color,i,n)} recurring={t.recurring} first={i===0} />
        ))}
        <div style={{fontSize:11.5,color:'var(--text-tertiary)',marginTop:12,lineHeight:1.5}}>{cat.note}</div>
      </div>
    </div>
  );
}

// ── Add-transaction sheet (opaque; grabber for iOS placement) ──
const fieldStyle = {width:'100%',boxSizing:'border-box',background:'var(--surface-backdrop)',border:'1px solid var(--border-hairline)',borderRadius:8,padding:'10px 12px',fontSize:14,color:'var(--text-body)',fontFamily:'var(--font-ui)',outline:'none'};
const lblStyle = {fontSize:11,fontWeight:700,letterSpacing:'0.08em',textTransform:'uppercase',color:'var(--text-secondary)',marginBottom:6};

function AddSheet({ open, onClose, onSave, grabber }) {
  const [kind, setKind] = React.useState('expense');
  const [amount, setAmount] = React.useState('');
  const [desc, setDesc] = React.useState('');
  const [catId, setCatId] = React.useState(D0.cats[0].id);
  const [forWho, setForWho] = React.useState('');
  const [recurring, setRecurring] = React.useState(false);
  const valid = parseFloat(amount) > 0 && desc.trim().length > 0;
  const save = () => {
    if (!valid) return;
    onSave({ date:'Jan 15', desc:desc.trim(), amount:Math.round(parseFloat(amount)), kind, catId:kind==='expense'?catId:null, forWho:forWho.trim()||'Me', recurring });
    setAmount(''); setDesc(''); setForWho(''); setRecurring(false); setKind('expense');
  };
  const segBtn = (k, label, color) => (
    <div onClick={()=>setKind(k)} style={{flex:1,textAlign:'center',padding:'9px 0',borderRadius:8,cursor:'pointer',fontSize:13,fontWeight:700,fontFamily:'var(--font-ui)',
      border:kind===k?`1px solid ${color}`:'1px solid var(--border-hairline)',
      background:kind===k?`color-mix(in oklab, ${color}, transparent 88%)`:'transparent',
      color:kind===k?color:'var(--text-secondary)'}}>{label}</div>
  );
  return (
    <div style={{position:'absolute',inset:0,zIndex:40,pointerEvents:open?'auto':'none'}} aria-hidden={!open}>
      <div onClick={onClose} style={{position:'absolute',inset:0,background:'rgba(5,23,48,0.6)',opacity:open?1:0,transition:'opacity var(--bbva-motion-push)'}}></div>
      <div data-screen-label="Add Transaction" style={{position:'absolute',left:0,right:0,bottom:0,maxHeight:'88%',overflowY:'auto',background:'var(--surface-app)',borderTop:'1px solid var(--border-hairline)',borderRadius:'16px 16px 0 0',padding:'10px 18px 20px',boxSizing:'border-box',transform:open?'translateY(0)':'translateY(102%)',transition:'transform var(--bbva-motion-push)',fontFamily:'var(--font-ui)'}}>
        {grabber ? <div style={{width:36,height:5,borderRadius:3,background:'var(--border-hairline)',margin:'0 auto 10px'}}></div> : <div style={{height:6}}></div>}
        <div style={{display:'flex',alignItems:'baseline',justifyContent:'space-between',marginBottom:14}}>
          <div style={{fontSize:15,fontWeight:700,color:'var(--text-body)'}}>Add transaction</div>
          <div onClick={onClose} style={{fontSize:13,fontWeight:600,color:'var(--bbva-accent-aqua)',cursor:'pointer'}}>Cancel</div>
        </div>
        <div style={{display:'flex',gap:8,marginBottom:14}}>
          {segBtn('expense','Expense','#F07285')}
          {segBtn('income','Income','#35B392')}
        </div>
        <div style={{marginBottom:12}}>
          <div style={lblStyle}>Amount · {D0.currency}</div>
          <input inputMode="decimal" value={amount} onChange={e=>setAmount(e.target.value.replace(/[^0-9.]/g,''))} placeholder="0" style={{...fieldStyle,fontSize:24,fontWeight:600,fontVariantNumeric:'tabular-nums'}} />
        </div>
        <div style={{marginBottom:12}}>
          <div style={lblStyle}>Description</div>
          <input value={desc} onChange={e=>setDesc(e.target.value)} placeholder="Groceries" style={fieldStyle} />
        </div>
        {kind==='expense' ? (
          <div style={{marginBottom:12}}>
            <div style={lblStyle}>Category</div>
            <div style={{display:'flex',flexWrap:'wrap',gap:8}}>
              {D0.cats.map(c=>(
                <div key={c.id} onClick={()=>setCatId(c.id)} style={{display:'flex',alignItems:'center',gap:6,padding:'7px 11px',borderRadius:999,cursor:'pointer',fontSize:12,fontWeight:600,
                  border:catId===c.id?'1px solid var(--bbva-accent-aqua)':'1px solid var(--border-hairline)',
                  color:catId===c.id?'var(--text-body)':'var(--text-secondary)',background:catId===c.id?'rgba(73,165,230,0.1)':'transparent'}}>
                  <span style={{width:8,height:8,borderRadius:4,background:c.color}}></span>{c.name}
                </div>
              ))}
            </div>
          </div>
        ) : null}
        <div style={{marginBottom:12}}>
          <div style={lblStyle}>For</div>
          <input value={forWho} onChange={e=>setForWho(e.target.value)} placeholder="Me" style={fieldStyle} />
        </div>
        <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',padding:'4px 0 2px',marginBottom:8}}>
          <div><div style={{fontSize:13,color:'var(--text-body)'}}>Recurring</div><div style={{fontSize:11,color:'var(--text-tertiary)',marginTop:1}}>repeats monthly</div></div>
          <div onClick={()=>setRecurring(!recurring)} style={{width:44,height:26,borderRadius:13,cursor:'pointer',background:recurring?'var(--bbva-teal)':'var(--bbva-line)',position:'relative',transition:'background 160ms'}}>
            <div style={{position:'absolute',top:3,left:recurring?21:3,width:20,height:20,borderRadius:10,background:'#E8EEF5',transition:'left 160ms'}}></div>
          </div>
        </div>
        <div style={{display:'flex',alignItems:'baseline',justifyContent:'space-between',padding:'8px 0 14px',borderTop:'1px solid var(--border-hairline)'}}>
          <div style={{fontSize:13,color:'var(--text-body)'}}>Date</div>
          <div style={{fontSize:12,color:'var(--text-tertiary)',fontVariantNumeric:'tabular-nums'}}>{D0.todayLabel}</div>
        </div>
        <div onClick={save} style={{textAlign:'center',padding:'12px 0',borderRadius:8,fontSize:14,fontWeight:700,cursor:valid?'pointer':'default',background:valid?'var(--bbva-accent-aqua)':'var(--bbva-line)',color:valid?'#051730':'var(--bbva-ink-faint)'}}>Save transaction</div>
      </div>
    </div>
  );
}

// ── App shell: home ⇄ detail push + add sheet. addAction(open) renders the kit's own button. ──
function LedgerApp({ height = '100%', topInset = 0, addAction = null, sheetGrabber = false }) {
  const [txs, setTxs] = React.useState(D0.transactions);
  const [view, setView] = React.useState(null);
  const [pos, setPos] = React.useState('home');
  const [mounted, setMounted] = React.useState(false);
  const [sheetOpen, setSheetOpen] = React.useState(false);
  const push = (id) => { setView(id); setMounted(true); requestAnimationFrame(()=>requestAnimationFrame(()=>setPos('detail'))); };
  const pop = () => { setPos('home'); setTimeout(()=>{ setMounted(false); setView(null); }, 360); };
  const paneStyle = { position:'absolute', inset:0, overflowY:'auto', overflowX:'hidden', background:'var(--surface-app)', transition:'transform var(--bbva-motion-push)' };
  const inset = topInset ? <div style={{height:topInset,background:'var(--bbva-navy)'}}></div> : null;
  return (
    <div style={{position:'relative',height,overflow:'hidden',background:'var(--surface-app)',fontFamily:'var(--font-ui)',color:'var(--text-body)'}}>
      <div style={{...paneStyle,zIndex:1,transform:`translateX(${pos==='detail'?'-28%':'0'})`,paddingBottom:76,boxSizing:'border-box'}} data-screen-label="Home">{inset}<HomePane txs={txs} onOpen={push} /></div>
      {mounted ? <div style={{...paneStyle,zIndex:2,boxShadow:'var(--bbva-push-shadow)',transform:`translateX(${pos==='detail'?'0':'102%'})`,paddingBottom:76,boxSizing:'border-box'}} data-screen-label="Detail">{inset}<DetailPane catId={view} txs={txs} onBack={pop} /></div> : null}
      {addAction ? addAction(()=>setSheetOpen(true)) : null}
      <AddSheet open={sheetOpen} grabber={sheetGrabber} onClose={()=>setSheetOpen(false)} onSave={(t)=>{ setTxs([t,...txs]); setSheetOpen(false); if (mounted) pop(); }} />
    </div>
  );
}

Object.assign(window, { BancomerLedgerApp: LedgerApp, BancomerHomePane: HomePane, BancomerDetailPane: DetailPane, BancomerAddSheet: AddSheet });
