{
      name: "FsChecker-Errors-Agg",
      sql: "select
  kernelVersion,
  sum(errorCount) as HostWithFsErrors,
  sum(goodCount) as GoodHosts,
  group_concat(errorHostname,'') as HostWithErrors,
  group_concat(errorMessage,'') as ErrorMessage
from
(
  select *
  from
  (
    select
      Payload->>'$.spec.hostname' as hostName,
      case when Payload->>'$.status.report.ErrorMessage' = 'null' then null else Payload->>'$.spec.hostname' end as errorHostname,
      case when Payload->>'$.status.report.ErrorMessage' = 'null' then null else Payload->>'$.status.report.ErrorMessage' end as errorMessage,
      case when Payload->>'$.status.report.ErrorMessage' = 'null' then 0 else 1 end as errorCount,
      case when Payload->>'$.status.report.ErrorMessage' = 'null' then 1 else 0 end as goodCount
    from
      k8s_resource
    where ApiKind = 'WatchDog' and
    Payload->>'$.spec.checkername' like 'filesystemchecker%'
  ) as fsChecker
  left join
  (
    select 
      Name,
      kernelVersion
    from nodeDetailView
  ) as pod
  on ( binary fsChecker.hostName = pod.Name  )
) as ss
group by kernelVersion ",
    }
