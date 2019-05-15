{
      name: "Pods in prd-sam that use pod IP but are missing the ip address request",
      sql: "select * from (
select
  namespace,
  name,
  (case when Payload->>'$.spec.containers[*].resources.limits.\"sam.sfdc.net/ip-address\"' is NULL then 0 else 1 end) as HasIpRequest,
  (case when Payload->>'$.status.hostIP' != Payload->>'$.status.podIP' then 1 else 0 end) as UsePodIP
from k8s_resource where apikind = 'Pod' and controlEstate = 'prd-sam' and IsTombstone=0
) as ss
where HasIpRequest = 0 and UsePodIP = 1",
    }
