{
    watchdogFrequency: "15m",
    name: "WatchdogSuccessCount",
    sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate, 
'sql.checkerFailCount' as Metric, FailureCount as Value, CONCAT('CheckerName=',CheckerName) as Tags
from (
  select
    CheckerName,
    SUM(FailureCount) as FailureCount
  from
  (
    select
      Payload->>'$.status.report.CheckerName' as CheckerName,
      case when Payload->>'$.status.report.Success' = 'false' then 1 else 0 end as FailureCount
    from k8s_resource
    where ApiKind = 'WatchDog'
  ) as ss
  where CheckerName not like 'Sql%' and CheckerName not like 'MachineCount%'
  group by CheckerName
) as ss2
union all
select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate, 
'sql.checkerSuccessCount' as Metric, SuccessCount as Value, CONCAT('CheckerName=',CheckerName) as Tags
from (
  select
    CheckerName,
    SUM(SuccessCount) as SuccessCount
  from
  (
    select
      Payload->>'$.status.report.CheckerName' as CheckerName,
      case when Payload->>'$.status.report.Success' = 'true' then 1 else 0 end as SuccessCount
    from k8s_resource
    where ApiKind = 'WatchDog'
  ) as ss3
  where CheckerName not like 'Sql%' and CheckerName not like 'MachineCount%'
  group by CheckerName
) as ss4",
  }

