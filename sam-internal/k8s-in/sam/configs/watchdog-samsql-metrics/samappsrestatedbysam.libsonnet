{
      watchdogFrequency: "15m",
      name: "SamAppsRestatedBySam",
      sql: "select
  UPPER(kingdom) as Kingdom,
  'NONE' as SuperPod,
  ControlEstate as Estate,
  'sql.samAppChangedBySamLastHour' as Metric,
  CONCAT('ChangedLastHour=',appChangedBySamInLastHour) as Tags,
  count as Value
from
(

select
  kingdom,
  controlEstate,
  appChangedBySamInLastHour,
  COUNT(*) as count
from
(
  select
    SUBSTRING(controlEstate,1,3) as kingdom,
    controlEstate,
    namespace,
    ownerDeployment,
    titleLine,
    sum(rsCount) as rsCount,
    sum(replicas) as replicaCount,
    GROUP_CONCAT(rsName,'') as rsNames,
    MIN(ageInHours) as minRsAgeHours,
    MAX(ageInHours) as maxRsAgeHours,
    CASE WHEN MIN(ageInHours)<1.0 and sum(rsCount)>1 THEN 'yes' ELSE 'no' END as appChangedBySamInLastHour
  from
  (
    select
      name as rsName,
      namespace,
      controlEstate,
      Payload->>'$.metadata.annotations.titleLine' as titleLine,
      Payload->>'$.metadata.ownerReferences[0].name' as ownerDeployment,
      Payload->>'$.spec.replicas' as replicas,
      TIMESTAMPDIFF(MINUTE, STR_TO_DATE(Payload->>'$.metadata.creationTimestamp','%Y-%m-%dT%H:%i:%s'), NOW())/60.0 as ageInHours,
      1 as rsCount
    from
      k8s_resource
    where
      ApiKind = 'ReplicaSet'
  ) as ss
  where not ownerDeployment is null and not titleLine is null
  group by controlEstate, namespace, ownerDeployment, titleLine
  having replicaCount > 0
) as ss2
group by kingdom, controlEstate, appChangedBySamInLastHour
) as ss3",
   }

