{
      name: "FailedCreatePodSandBox",
      note: "This shows all system-wide k8s events with reason equal to FailedCreatePodSandBox in last 1 hour",
      multisql: [
        {
          name: "Agg",
          sql: "select *
from (
select
  controlEstate, host,
  count(*) as count,
  group_concat(podName) as Pods
from (
select
  controlEstate,
  concat(namespace,'/',CAST(Payload->>'$.involvedObject.name' as CHAR CHARACTER SET utf8)) as podName,
  namespace,
  Payload->>'$.message' as message,
  Payload->>'$.source.host' as host,
  Payload->>'$.involvedObject.name' as name,
  Payload->>'$.lastTimestamp' as lastTimestamp,
  TIMESTAMPDIFF(MINUTE, STR_TO_DATE(Payload->>'$.lastTimestamp', '%Y-%m-%dT%H:%i:%sZ'), UTC_TIMESTAMP()) as lastTimestampAgeInMin
from k8s_resource where ApiKind = 'Event' and Payload->>'$.reason' = 'FailedCreatePodSandBox'
order by lastTimestamp desc
) as ss
where lastTimestampAgeInMin < 60
group by controlEstate, host
) as ss2
order by count desc",
        },
{
          name: "Pods",
          sql: "select * from (
select
  controlEstate,
  namespace,
  Payload->>'$.message' as message,
  Payload->>'$.source.host' as host,
  Payload->>'$.involvedObject.name' as name,
  Payload->>'$.lastTimestamp' as lastTimestamp,
  TIMESTAMPDIFF(MINUTE, STR_TO_DATE(Payload->>'$.lastTimestamp', '%Y-%m-%dT%H:%i:%sZ'), UTC_TIMESTAMP()) as lastTimestampAgeInMin
from k8s_resource where ApiKind = 'Event' and Payload->>'$.reason' = 'FailedCreatePodSandBox'
order by lastTimestamp desc
) as ss
where lastTimestampAgeInMin < 60
",
        },
      ],
    }