{
      name: "Prd Sam Sandbox Unscheduled Pods",
      note: "Queries to help debug scheduler issues",
      multisql: [
        {
          name: "Unscheduled Pods Except csc-sam",
          sql: "select Name, Namespace, Payload->>'$.status.conditions[0].message' as Message
from k8s_resource
where Payload->>'$.status.conditions[0].reason' = 'Unschedulable'
and controlEstate = 'prd-sam'
and Payload->>'$.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]' = 'prd-sam'
and Namespace != 'csc-sam'",
        },
        {
          name: "Unscheduled Pods csc-sam (many of these are missed tombstones)",
          sql: "select Name, Namespace, Payload->>'$.status.conditions[0].message' as Message
from k8s_resource
where Payload->>'$.status.conditions[0].reason' = 'Unschedulable'
and controlEstate = 'prd-sam'
and Payload->>'$.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]' = 'prd-sam'
and Namespace = 'csc-sam'",
        },
        {
          name: "Nodes",
          sql: "select name, MinionPool, OutOfDisk, MemoryPressure, DiskPressure, Ready
from nodeDetailView
where controlEstate = 'prd-sam' and MinionPool = 'prd-sam'
order by Ready, OutOfDisk",
        },
        {
          name: "IPs used by namespace",
          sql: "select namespace, sum(ipCount) as ips, group_concat(samAppName, '', '') as AppNames
from (
select
  namespace,
  Payload->>'$.spec.controlMap.app' as samAppName,  
  case when Payload->>'$.spec.customerApp.system.functions[0].count' is not null then Payload->>'$.spec.customerApp.system.functions[0].count' else 0 end +
  case when Payload->>'$.spec.customerApp.system.functions[1].count' is not null then Payload->>'$.spec.customerApp.system.functions[1].count' else 0 end +
  case when Payload->>'$.spec.customerApp.system.functions[2].count' is not null then Payload->>'$.spec.customerApp.system.functions[2].count' else 0 end as ipCount
from
  k8s_resource
where
  apiKind = 'SamApp'
  and
  Payload->>'$.spec.controlMap.pool' = 'prd/prd-sam'
  and Payload->>'$.spec.customerApp.system.functions[0].hostnetwork' != 'true'
) as ss
group by namespace
order by sum(ipCount) desc",
        },
      ],
    }
