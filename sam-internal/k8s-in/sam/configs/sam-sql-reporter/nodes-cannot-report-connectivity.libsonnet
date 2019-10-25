{
    name: "Nodes with broken POD network connectivity",
    sql: "select NodeName, ControlEstate, datediff(utc_timestamp(),str_to_date(Payload->>'$.metadata.creationTimestamp','%Y-%m-%dT%H:%i:%sZ')) AS NodeAgeInDays, HasUnHealthyCrd, 
	json_extract(Payload, concat('$.status.conditions[',substring(json_search(Payload->>'$.status.conditions', 'one', 'KubeletReady'), 4, 1),'].status')) as KubeletReady,
case
    when substring(ControlEstate,1,3) in ('CDU','HIO','SYD','TTD','WAX','YHU','YUL') then 'AWS'
    when substring(ControlEstate,1,3) in ('DFW','FRF','HND','IAD','ORD','PAR','PHX','PRD','UKB','XRD') then 'v14.2'
    when substring(ControlEstate,1,3) in ('CDG','FRA','IA2','IA4','IA5','LO2','LO3','PH2','RD1','RZ1') then 'v17.x'
    else 'Unknown'
end as NetworkVersion 
from (

select NodeName, sum(HasHealthyCrd) as HasHealthyCrd, sum(HasUnHealthyCrd) as HasUnHealthyCrd, sum(HasRunningPod) as HasRunningPod from (

  select Payload->>'$.spec.nodeName' as NodeName,
  0 as HasHealthyCrd,
  0 as HasUnHealthyCrd,
  1 as HasRunningPod
  from k8s_resource
  where apikind = 'Pod' 
  	and namespace = 'sam-system' 
  	and name like 'sam-network-reporter%' 
  	and Payload->>'$.status.phase' = 'Running' 
  	and Payload->>'$.status.message' is null
	and Payload->>'$.metadata.deletionTimestamp' is null

union all

  select TRIM('connectivitylabelerchecker-' FROM name) as NodeName,
  (case when Payload->>'$.status.report.Success' = 'true' then 1 else 0 end) as HasHealthyCrd,
  (case when Payload->>'$.status.report.Success' = 'true' then 0 else 1 end) as HasUnHealthyCrd,
  0 as HasRunningPod
  from k8s_resource
  where apikind = 'watchdog' 
                and name like 'connectivitylabelerchecker-%' 
                and TIMESTAMPDIFF(MINUTE, STR_TO_DATE(Payload->>'$.status.report.ReportCreatedAt', '%Y-%m-%dT%H:%i:%s.'), UTC_TIMESTAMP())<90

) sq1
group by NodeName
having HasHealthyCrd <> 1) sq2
left join k8s_resource 
on sq2.NodeName=k8s_resource.Name
where apikind='Node' and Name not like '%slbminion%'
order by ControlEstate",
}