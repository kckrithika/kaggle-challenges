{
     watchdogFrequency: "15m",
     name: "WatchdogSuccessPctByKingdom",
     sql: "select UPPER(kingdom) as Kingdom, 'NONE' as SuperPod, ControlEstate as Estate,
'sql.checkerPassPctPerKingdom' as Metric, SuccessPct as Value, CONCAT('CheckerName=',CheckerName) as Tags
from (
  select
    ControlEstate,
    Kingdom,
    CheckerName,
    SUM(SuccessCount)/(SUM(SuccessCount)+SUM(FailureCount)) as SuccessPct
  from
  (
    select
      substr(ControlEstate,1,3) AS Kingdom,
      ControlEstate,
      Payload->>'$.status.report.CheckerName' as CheckerName,
      case when Payload->>'$.status.report.Success' = 'true' then 1 else 0 end as SuccessCount,
      case when Payload->>'$.status.report.Success' = 'false' then 1 else 0 end as FailureCount
    from k8s_resource
    where ApiKind = 'WatchDog'
  ) as ss
  where CheckerName not like 'Sql%' and CheckerName not like 'MachineCount%'
  group by CheckerName, ControlEstate, Kingdom
) as ss2",
  }

