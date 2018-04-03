{
  sql_alerts: [
    {
      name: "Bad-Customer-Deployments-Production",
      instructions: "The following nodes are reported as bad customer deployments in Production",
      alertThreshold: "30m",
      alertFrequency: "24h",
      watchdogFrequency: "24h",
      sql: "SELECT * FROM
(
  SELECT
    ControlEstate,
    Namespace,
    Name,
    JSON_EXTRACT(Payload, '$.metadata.annotations.\"smb.sam.data.sfdc.net/emailTo\"') AS email,
    JSON_EXTRACT(Payload, '$.spec.replicas') AS desiredReplicas,
    JSON_EXTRACT(Payload, '$.status.availableReplicas') AS availableReplicas,
    JSON_EXTRACT(Payload, '$.status.replicas') AS replicas,
    JSON_EXTRACT(Payload, '$.status.readyReplicas') AS readyReplicas,
    JSON_EXTRACT(Payload, '$.status.updatedReplicas') AS updatedReplicas,
    CONCAT('http://dashboard-',SUBSTR(ControlEstate, 1, 3),'-sam.csc-sam.prd-sam.prd.slb.sfdc.net/#!/deployment/',Namespace,'/',Name,'?namespace=',Namespace) AS Url
  FROM k8s_resource
  WHERE ApiKind = 'Deployment'
) AS ss
WHERE
  ( Namespace != 'sam-watchdog' AND Namespace != 'sam-system' AND Namespace != 'csc-sam') AND
  (availableReplicas != desiredReplicas OR availableReplicas IS NULL) AND
  NOT ControlEstate LIKE 'prd-%' AND
  desiredReplicas != 0",
    },
  ],
}
