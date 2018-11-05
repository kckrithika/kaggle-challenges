{
      name: "FsChecker-Errors",
      sql: "select
  hostName, kernelVersion, errorMessage, controlEstate  
from
(
  select
    controlEstate,
    Payload->>'$.spec.hostname' as hostName,
    Payload->>'$.status.report.ErrorMessage' as errorMessage
  from
    k8s_resource
  where ApiKind = 'WatchDog' and
  Payload->>'$.spec.checkername' like 'filesystemchecker%' and
  Payload->>'$.status.report.ErrorMessage' != 'null'
) as fsChecker
left join
(
  select 
    Name,
    kernelVersion
  from nodeDetailView
) as pod
on ( binary fsChecker.hostName = pod.Name )",
    }
