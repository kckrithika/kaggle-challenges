{
    watchdogFrequency: "1m",
    name: "IpAddressResourceCapacity",
    sql: "select
  UPPER(SUBSTRING(controlEstate,1,3)) as Kingdom,
  'NONE' as SuperPod,
  controlEstate as Estate,
  'sql.ipAddressResourceCapacity' as Metric,
  CONCAT('Capacity=',IpAddressCapacity) as Tags,
  count(*) as Value
from (
  select controlEstate, Payload->>'$.status.capacity.\"sam.sfdc.net/ip-address\"' as IpAddressCapacity
  from k8s_resource
  where apikind = 'Node' and controlEstate = 'prd-sam'
) as ss
group by controlEstate, IpAddressCapacity",
  }

