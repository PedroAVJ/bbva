// Synthetic ledger sample — manual, offline, on-device model. No real records.
window.BANCOMER_DATA = (() => {
  // Entity-fixed Coronita colors (color follows the entity, never the rank).
  const CATS = [
    { id:'housing', name:'Housing & utilities', color:'#9CCAF0', dark:true,  note:'Synthetic housing costs.' },
    { id:'health',  name:'Health',              color:'#3A6EA8', dark:false, note:'Synthetic healthcare commitments.' },
    { id:'debt',    name:'Debt',                color:'#6FAEE3', dark:true,  note:'Synthetic obligations with fixed schedules.' },
    { id:'food',    name:'Food & daily',        color:'#C7E1F8', dark:true,  note:'Synthetic day-to-day spending.' },
    { id:'ai',      name:'AI',                  color:'#4E8FD0', dark:false, note:'Synthetic software commitments.' }
  ];
  const T = (date, desc, amount, kind, catId, forWho, recurring) => ({ date, desc, amount, kind, catId, forWho, recurring });
  const transactions = [ // newest first
    T('Jan 15','Coffee',85,'expense','food','Me',false),
    T('Jan 14','Lunch',260,'expense','food','Me',false),
    T('Jan 12','Rides',430,'expense','food','Me',false),
    T('Jan 10','Transcription credits',340,'expense','ai','Me',false),
    T('Jan 9','Groceries',920,'expense','food','household',false),
    T('Jan 8','Prescriptions',780,'expense','health','mom',false),
    T('Jan 7','Camera sale',1200,'income',null,'Me',false),
    T('Jan 6','Power',500,'expense','housing','household',true),
    T('Jan 5','Device plan',1500,'expense','debt','Me',true),
    T('Jan 5','Fitness',1200,'expense','health','Me',true),
    T('Jan 3','Groceries',1850,'expense','food','household',false),
    T('Jan 3','Internet',1000,'expense','housing','household',true),
    T('Jan 2','AI assistant',1800,'expense','ai','Me',true),
    T('Jan 2','Family healthcare',4500,'expense','health','family',true),
    T('Jan 1','Education plan',2500,'expense','debt','Ana',true),
    T('Jan 1','Rent',7500,'expense','housing','household',true),
    T('Jan 1','Salary',45000,'income',null,'Me',true)
  ];
  return { dateLabel:'Thu, Jan 15', todayLabel:'Today · Jan 15', rangeLabel:'Jan 1–15', currency:'MXN', cats:CATS, transactions };
})();
