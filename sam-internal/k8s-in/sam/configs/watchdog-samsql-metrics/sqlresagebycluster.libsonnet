{
     watchdogFrequency: "15m",
     name: "dbResProduceAgePerClusterInMin",
     sql: "select
  'GLOBAL' as Kingdom,
  'NONE' as SuperPod,
  'global' as Estate,
  'sql.dbResProduceAgePerClusterInMin' as Metric,
  CONCAT('controlEstate=',controlEstate) as Tags,
  AVG(produceAgeMinutes) as Value
from (
  select
    controlEstate,
    floor(time_to_sec(timediff(now(),FROM_UNIXTIME(ProduceTime / 1000000000)))/60) as produceAgeMinutes
  from k8s_resource
) as ss
group by controlEstate",
   }

