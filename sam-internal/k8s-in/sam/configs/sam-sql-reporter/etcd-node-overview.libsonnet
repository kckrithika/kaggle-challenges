{
    name: "Etcd Node Overview",
    note: "View of ETCD health based on etcdChecker CRD.  Stale means the watchdog CRD has not been updated in > 3 hours.  Keep in mind the etcd watcher does not know what etcd nodes are in the ring.  Some errors are general broken etcd and some are members not added.",
    multisql: [
    {
      name: "Overview", 
      sql: "select
  controlEstate,
  sum(case when Status = 'healthy' then 1 end) as HealthyCount,
  group_concat(case when NodeNum = 'n1-1' then Status else NULL end) as node1_1,
  group_concat(case when NodeNum = 'n2-1' then Status else NULL end) as node2_1,
  group_concat(case when NodeNum = 'n3-1' then Status else NULL end) as node3_1,
  group_concat(case when NodeNum = 'n1-2' then Status else NULL end) as node1_2,
  group_concat(case when NodeNum = 'n2-2' then Status else NULL end) as node2_2,
  group_concat(case when NodeNum = 'n3-2' then Status else NULL end) as node3_2,
  group_concat(case when NodeNum = 'n1-3' then Status else NULL end) as extra_1_3,
  group_concat(case when NodeNum = 'n3-2' then Status else NULL end) as extra_3_2
  from
(
select
  controlEstate,
  (case
    when Success = 'true' and ReportAgeInHours<90 then 'healthy'
    when Success = 'true' and ReportAgeInHours>=90 then concat('healthy<br>(stale ',ReportAgeInHours,' hr)')
    when Success = 'false' and ReportAgeInHours<90 then 'bad'
    when Success = 'false' and ReportAgeInHours>=90 then concat('bad<br>(stale ',ReportAgeInHours,' hr)')
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