{
    name: "Stuck Init Containers Including MadKub",
    sql: "select 
  controlEstate, 
  namespace, 
  name as podName,
  Payload->>'$.spec.nodeName' as nodeName, 
  Payload->>'$.status.phase' as phase,
  Payload->>'$.status.initContainerStatuses[*].restartCount' as initContainerRestartCount,
  Payload->>'$.status.initContainerStatuses[*].state.*.message' as initContainerMessage,
  Payload->>'$.status.message' as message
from k8s_resource
where apikind = 'Pod' and Payload->>'$.status.phase' = 'Pending' and Payload->>'$.status.initContainerStatuses[*].state.*.message' is not null",
}
