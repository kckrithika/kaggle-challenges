{
     watchdogFrequency: "15m",
     name: "SqlResourceCounts",
     sql: "select
  'GLOBAL' as Kingdom, 
  'NONE' as SuperPod,
  'global' as Estate,
  'sql.dbResTotal' as Metric,
  '' as Tags,
  COUNT(*) as Value
from k8s_resource 
union all
select 
  'GLOBAL' as Kingdom, 
  'NONE' as SuperPod, 
  'global' as Estate, 
  'sql.dbResPerCluster' as Metric,
  CONCAT('controlEstate=',controlEstate) as Tags,
  COUNT(*) as Value
from k8s_resource 
group by controlEstate",
   }

