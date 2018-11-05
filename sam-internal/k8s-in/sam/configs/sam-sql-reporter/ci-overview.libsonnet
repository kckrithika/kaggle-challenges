{
      name: "CI Overview",
      sql: "select
  samApp.controlEstate,
  samApp.name,
  samApp.namespace,
  samAppCreationTimestamp,
  bundleCreationTimestamp,
  samAppNumResourceLinks,
  bundleState,
  bundleStatus,
  samappStatus
from
(
select
  controlEstate,
  name,
  namespace,
  json_length(Payload->'$.status.resourceLinks') as samAppNumResourceLinks,
  Payload->>'$.metadata.creationTimestamp' as samAppCreationTimestamp,
  Payload->>'$.status' as samappStatus
from k8s_resource
where ApiKind = 'SamApp'
and Payload->>'$.metadata.labels.deployed_by' is null
) samApp

left join

(
select
  controlEstate,
  name,
  namespace,
  Payload->>'$.status.state' as bundleState,
  Payload->>'$.status' as bundleStatus,
  Payload->>'$.metadata.creationTimestamp' as bundleCreationTimestamp
from k8s_resource
where ApiKind = 'Bundle'
) bundle

on samApp.controlEstate = bundle.controlEstate and samApp.name = bundle.name and samApp.namespace = bundle.namespace",
    }