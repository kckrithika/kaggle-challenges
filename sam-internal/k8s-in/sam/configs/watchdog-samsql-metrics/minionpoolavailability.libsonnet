{
    watchdogFrequency: "15m",
    name: "MinionPoolAvailability",
    sql: "select
	'GLOBAL' as Kingdom,
	'NONE' as SuperPod,
	'global' as Estate,
	'sql.minionPoolAvailability' as Metric,
	(sum(case when ReadyCount = 0 then 0 else 1 end)+0.0) / count(*) as Value
from (
select
	pool,
	sum(case when KubeletReady = 'True' then 1 else 0 end) as ReadyCount,
	sum(case when KubeletReady = 'True' then 0 else 1 end) as NotReadyCount
from (
select
	Payload->>'$.metadata.labels.pool' as pool,
	json_unquote(json_extract(Payload, concat('$.status.conditions[',substring(json_search(Payload->>'$.status.conditions', 'one', 'KubeletReady'), 4, 1),'].status'))) as KubeletReady
from k8s_resource
where apiKind = 'Node' and (ControlEstate not like 'prd%') and (ControlEstate not like 'xrd%')
) as ss
where pool not like '%ceph%' and pool not like '%chatbot%' and pool not like '%sfstore%'
group by pool
) as ss2",
}

