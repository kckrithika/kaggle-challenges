{
    name: "Etcd Node Overview",
    note: "View of ETCD health based on etcdChecker CRD.  Stale means the watchdog CRD has not been updated in > 1 hours.  Keep in mind the etcd watcher does not know what etcd nodes are in the ring.  Some errors are general broken etcd and some are members not added.  Also, a host can be online and have working etcd but it will show failing here because of a watchdog issue",
    multisql: [
    {
      name: "Overview", 
      sql: "select
  controlEstate,
  sum(case when Status = 'good' then 1 end) as HealthyCount,
  group_concat(case when NodeNum = 'n1-1' then Status else NULL end) as node1_1,
  group_concat(case when NodeNum = 'n2-1' then Status else NULL end) as node2_1,
  group_concat(case when NodeNum = 'n3-1' then Status else NULL end) as node3_1,
  group_concat(case when NodeNum = 'n1-2' then Status else NULL end) as node1_2,
  group_concat(case when NodeNum = 'n2-2' then Status else NULL end) as node2_2
  from
(
select
  controlEstate,
  (case
    when Success = 'true' and ReportAgeInHours<1 then 'good'
    when Success = 'true' and ReportAgeInHours>=1 then concat('STALE ',ReportAgeInHours,' hr')
    when Success = 'false' and ReportAgeInHours<1 then 'FAILING'
    when Success = 'false' and ReportAgeInHours>=1 then concat('STALE ',ReportAgeInHours,' hr')
  end) as Status,
  NodeNum
from
(

select
  controlEstate,
  Payload->>'$.spec.checkername' as checkerName,
  Payload->>'$.status.report.Success' as Success,
  TIMESTAMPDIFF(HOUR, STR_TO_DATE(Payload->>'$.status.report.ReportCreatedAt', '%Y-%m-%dT%H:%i:%s.'), UTC_TIMESTAMP()) as ReportAgeInHours,
  concat('n',MID(Payload->>'$.spec.checkername',length(Payload->>'$.spec.checkername')-19,3)) as NodeNum
from k8s_resource
where
  apikind = 'watchdog'
  and Payload->>'$.spec.checkername' like 'etcdchecker-%kubeapi%'

) as ss
) as ss2
group by ControlEstate
order by controlEstate",
      },
      {
        name: "Not Ready KubeApi Servers in Production",
        sql: "select controlEstate, name, produceAgeInMin, Messages from (
  select
    controlEstate,
    name,
    floor((time_to_sec(timediff(utc_timestamp(),from_unixtime((ProduceTime / 1000000000.0)))) / 60.0)) as ProduceAgeInMin,
    json_unquote(json_extract(Payload, concat('$.status.conditions[',substring(json_search(Payload->>'$.status.conditions', 'one', 'KubeletReady'), 4,1),'].status'))) as KubeletReady,
    Payload->>'$.status.conditions[*].message' as Messages,
    isTombstone
  from k8s_resource 
  where ApiKind = 'node' and ControlEstate not like '%prd%' and controlestate not like '%xrd%' and name like '%kubeapi%' and isTombstone = 0
) as ss
where ((KubeletReady is null) or (KubeletReady != 'True') or (ProduceAgeInMin > 60))
order by controlEstate, name"
      },
      {
        name: "Detail View",
        sql: "select
  controlEstate,
  Payload->>'$.spec.checkername' as checkerName,
  TIMESTAMPDIFF(HOUR, STR_TO_DATE(Payload->>'$.status.report.ReportCreatedAt', '%Y-%m-%dT%H:%i:%s.'), UTC_TIMESTAMP()) as ReportAgeInHours,
  Payload->>'$.status.report.Success' as Success,
  Payload->>'$.status.report.ErrorMessage' as ErrorMessage
from k8s_resource
where
  apikind = 'watchdog'
  and Payload->>'$.spec.checkername' like 'etcdchecker-%kubeapi%'
order by controlEstate, Payload->>'$.spec.checkername'"
      },
      ] 
}