{
    watchdogFrequency: "15m",
    name: "HostRepairRebootCount",
    sql: "select
  'GLOBAL' as Kingdom,
  'NONE' as SuperPod,
  'global' as Estate,
  'sql.hostRepairLast7days' as Metric,
  COUNT(*) as Value,
  CONCAT('HealthyAfterReboot=',Healthy) as Tags
from (
  select
    Payload->>'$.observation.healthInfo.health' as Healthy,
    TIMESTAMPDIFF(MINUTE, STR_TO_DATE(Payload->>'$.spec.startTime','%Y-%m-%dT%H:%i:%s'), NOW())/60.0/24.0 as ageInDays
  from k8s_resource
  where ApiKind = 'HostRepair'
  ) as ss
where ageInDays < 7
group by Healthy",
  }