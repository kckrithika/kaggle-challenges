{
    name: "Sandbox-IPs-by-user",
    sql: "select
  namespace,
  Payload->>'$.spec.controlMap.app' as samAppName,
  Payload->>'$.spec.controlMap.annotations.date' as prDate,
  Payload->>'$.spec.controlMap.annotations.titleLine' as titleLine,
  Payload->>'$.spec.controlMap.pool' as pool,
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
  ",
}
