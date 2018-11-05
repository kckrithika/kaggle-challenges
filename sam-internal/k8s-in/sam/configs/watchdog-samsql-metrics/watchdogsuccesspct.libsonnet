{
     watchdogFrequency: "15m",
     name: "WatchdogSuccessPct",
     sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate, 
'sql.checkerPassPct' as Metric, SuccessPct as Value, CONCAT('CheckerName=',CheckerName) as Tags
from (
  select
    CheckerName,
    SUM(SuccessCount)/(SUM(SuccessCount)+SUM(FailureCount)) as SuccessPct
  from
  (
    select
      Payload->>'$.status.report.CheckerName' as CheckerName,
      case when Payload->>'$.status.report.Success' = 'true' then 1 else 0 end as SuccessCount,
      case when Payload->>'$.status.report.Success' = 'false' then 1 else 0 end as FailureCount
    from k8s_resource
    where ApiKind = 'WatchDog'
  ) as ss
  where CheckerName not like 'Sql%' and CheckerName not like 'MachineCount%'
  group by CheckerName
) as ss2",
  }

