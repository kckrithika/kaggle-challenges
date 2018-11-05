{
      name: "Customer App Restarts by SAM in Test Beds",
      note: "This is a list of customer SAM apps in prd-samdev and prd-samtest that have 2 or more ReplicaSets with the same manifest PR.  This generally indicates our controller has changed the PodSpecTemplate.  Use the DownloadRsCmd then diff the output files to see details",
      sql: "
select
  controlEstate,
  namespace,
  rsNames,
  rsCount,
  FLOOR(minRsAgeHours) as minRsAgeHours,
  FLOOR(maxRsAgeHours) as maxRsAgeHours,
  CONCAT('echo \\'',rsNames,'\\' | xargs -n 1 -t -I % sh -c \\'kubectl get --context ',controlEstate,' -n ',namespace,' -o yaml rs % > %.yaml\\'') as DownloadRsCmd
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
    REPLACE(GROUP_CONCAT(rsName,' '),',',' ') as rsNames,
    MIN(ageInHours) as minRsAgeHours,
    MAX(ageInHours) as maxRsAgeHours
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
    and (ControlEstate = 'prd-samdev' or ControlEstate = 'prd-samtest')
  ) as ss
  where not ownerDeployment is null and not titleLine is null
  group by controlEstate, namespace, ownerDeployment, titleLine
  having replicaCount > 0
) as ss2
where rsCount>1
order by minRsAgeHours",
    }
