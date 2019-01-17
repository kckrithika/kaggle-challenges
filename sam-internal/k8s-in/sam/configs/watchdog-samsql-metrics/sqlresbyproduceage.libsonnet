{
     watchdogFrequency: "15m",
     name: "SqlResByProduceAge",
     sql: "select
  'GLOBAL' as Kingdom,
  'NONE' as SuperPod,
  'global' as Estate,
  'sql.dbResByProduceAge' as Metric,
  CONCAT('produceAgeMin=',produceAgeMinutes) as Tags,
  COUNT(*) as Value
from (
  select 
    floor(time_to_sec(timediff(now(),FROM_UNIXTIME(ProduceTime / 1000000000)))/60/5)*5 as produceAgeMinutes
  from k8s_resource
) as ss
group by produceAgeMinutes",
   }

