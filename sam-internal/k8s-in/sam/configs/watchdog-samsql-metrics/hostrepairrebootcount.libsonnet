{
    watchdogFrequency: "15m",
    name: "HostRepairRebootCount",
    sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate, 'sql.hostRepairRebootCount' as Metric, SUM(Payload->>'$.status.details.totalRebootCount') as Value, '' as Tags
from k8s_resource
where ApiKind = 'HostRepair'",
  }

