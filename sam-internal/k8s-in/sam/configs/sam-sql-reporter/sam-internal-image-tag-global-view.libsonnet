{
  name: "Sam-Internal-Image-Tag-Global-View",
  sql: "Select
  control_estate,
  name,
  Json_unquote(Json_extract(`payload`, '$.spec.template.spec.containers[0].image'))
  from deploymentDetailView
  where Namespace = 'sam-system'
  and ownerLabel = 'sam'
 "
 }