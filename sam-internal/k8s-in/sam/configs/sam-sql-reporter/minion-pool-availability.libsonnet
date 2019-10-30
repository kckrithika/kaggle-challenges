{
      name: "Minion-Pool-Availability",
      sql: "select
	controlEstate,
	pool,
	sum(case when KubeletReady = 'True' then 1 else 0 end) as ReadyCount,
	sum(case when KubeletReady = 'True' then 0 else 1 end) as NotReadyCount,
	case when sum(case when KubeletReady = 'True' then 1 else 0 end) = 0 then 'RED' else '' end as PoolHasMinAvailability
from (
select
	controlEstate,
	Payload->>'$.metadata.labels.pool' as pool,
	json_unquote(json_extract(Payload, concat('$.status.conditions[',substring(json_search(Payload->>'$.status.conditions', 'one', 'KubeletReady'), 4, 1),'].status'))) as KubeletReady
from k8s_resource
where apiKind = 'Node' and (ControlEstate not like 'prd%') and (ControlEstate not like 'xrd%')
) as ss
where pool not like '%ceph%' and pool not like '%chatbot%' and pool not like '%sfstore%'
group by controlEstate, pool
order by ReadyCount",
    }
