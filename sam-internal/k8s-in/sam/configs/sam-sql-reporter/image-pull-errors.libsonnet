{
      name: "Image-Pull-Errors",
      sql: "select
  ControlEstate,
  Namespace,
  Payload->>'$.message' as Message,
  Payload->>'$.source.host' as Host,
  Payload->>'$.involvedObject.kind' as InvolvedObjKind,
  Payload->>'$.involvedObject.name' as InvolvedObjName,
  Payload->>'$.involvedObject.namespace' as InvolvedObjNamespace
from
  k8s_resource
where
  ApiKind like 'Event' and
  Payload->>'$.message' like '%ImagePullBackOff%'",
    }