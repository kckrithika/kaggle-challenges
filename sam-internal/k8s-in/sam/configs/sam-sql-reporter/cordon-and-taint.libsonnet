{
      name: "Nodes with cordon or taints",
      sql: "select
	controlEstate,
	name,
	json_unquote(json_extract(Payload, concat('$.status.conditions[',substring(json_search(Payload->>'$.status.conditions', 'one', 'KubeletReady'), 4, 1),'].status'))) as KubeletReady,
	payload->>'$.spec.unschedulable' as Cordoned,
	Payload->>'$.metadata.labels.\"node.sam.sfdc.net/rack\"' as rack,
	Payload->>'$.spec.taints' as Taints
from
	k8s_resource
where
	apikind = 'node' and
	(Payload->>'$.spec.taints' is not null or payload->>'$.spec.unschedulable' is not null) and controlEstate = 'prd-samtwo'
order by controlEstate, name",
    }