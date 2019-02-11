{
      name: "Bad-Customer-Deployments-V2",
      sql: "SELECT * FROM

  Select appName,
  namespace,
  controlEstate,
  overallStatus,
  samappMsg as error,
  bundleStatus as detailedStatus
  from crd_status_view
  where overallStatus != 'success'
 "
 }