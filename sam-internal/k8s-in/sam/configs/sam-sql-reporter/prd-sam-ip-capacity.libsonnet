{
      name: "Prd-SAM-IpAddress-Resource-Capacity",
      sql: "select name, Payload->>'$.status.capacity.\"sam.sfdc.net/ip-address\"' as IpAddressCapacity from k8s_resource where apikind = 'Node' and controlEstate = 'prd-sam'",
}
