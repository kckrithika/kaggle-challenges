{
      name: "TooManyPodsInNamespace",
      alertThreshold: "5m",
      alertFrequency: "336h",
      watchdogFrequency: "5m",
      alertProfile: "sam",
      alertAction: "businesshours_pagerduty",
      sql: "select * from (
  select 
    controlEstate, 
    namespace, 
    count(*) as podCount,
    count(distinct Payload->>'$.spec.nodeName') as nodeCount,
    sum(case when Payload->>'$.status.reason' = 'Evicted' then 1 else 0 end) as podEvictedCount,
    sum(case when Payload->>'$.status.phase' = 'Pending' then 1 else 0 end) as podPendingCount,
    sum(case when Payload->>'$.status.phase' = 'Running' then 1 else 0 end) as podRunningCount,
    left(group_concat(Payload->>'$.status.message'), 1024) as sampleMessages
  from k8s_resource
  where ApiKind = 'Pod'
  group by controlEstate, namespace
) as ss having podCount > (30*nodeCount) and podCount > 1000",
    }
