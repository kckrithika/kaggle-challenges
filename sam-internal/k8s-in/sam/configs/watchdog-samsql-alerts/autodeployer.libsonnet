{
            name: "SamControlDeployer",
            instructions: "The following SAM control stack components dont have a healhty autodeployer pod",
            alertThreshold: "20m",
            alertFrequency: "336h",
            watchdogFrequency: "5m",
            alertProfile: "sam",
            alertAction: "businesshours_pagerduty",
            sql: "select * from (
  select controlEstate
  from k8s_resource
  group by controlEstate
) as allce

left join

(
  select 
    controlEstate,
    name,
    Payload->>'$.status.availableReplicas' as availableReplicas,
    Payload->>'$.status.readyReplicas' as readyReplicas,
    Payload->>'$.status.updatedReplicas' as updatedReplicas,
    Payload->>'$.status.replicas' as replicas
  from k8s_resource
  where apikind = 'Deployment'
    and namespace = 'sam-system'
    and name = 'samcontrol-deployer'
) as ss

on allce.controlEstate = ss.controlEstate
where readyReplicas is null or readyReplicas < 1
and allce.controlEstate not like 'aws%'
and allce.controlEstate not like 'gsf%'",
    }

