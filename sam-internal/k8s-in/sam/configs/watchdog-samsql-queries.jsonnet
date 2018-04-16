{
  sql_alerts: [
    {
      name: "Customer-Production-Deployment-Availability-LessThan60%",
      instructions: "The following deployments are reported as bad customer deployments in Production. Debug Instructions: https://git.soma.salesforce.com/sam/sam/wiki/Debug-Failed-Deployment",
      alertThreshold: "30m",
      alertFrequency: "24h",
      watchdogFrequency: "15m",
      sql: "SELECT * FROM
(
  SELECT
    ControlEstate,
    Namespace,
    Name,
    JSON_EXTRACT(Payload, '$.metadata.annotations.\"smb.sam.data.sfdc.net/emailTo\"') AS email,
    JSON_EXTRACT(Payload, '$.spec.replicas') AS desiredReplicas,
    JSON_EXTRACT(Payload, '$.status.availableReplicas') AS availableReplicas,
    JSON_EXTRACT(Payload, '$.status.readyReplicas') AS readyReplicas,
    JSON_EXTRACT(Payload, '$.status.updatedReplicas') AS updatedReplicas,
    (JSON_EXTRACT(Payload, '$.spec.replicas') - JSON_EXTRACT(Payload, '$.status.availableReplicas')) AS kpodsDown,
    COALESCE(JSON_EXTRACT(Payload, '$.status.availableReplicas') /nullif(JSON_EXTRACT(Payload, '$.spec.replicas'), 0), 0) AS availability,
    CONCAT('http://dashboard-',SUBSTR(ControlEstate, 1, 3),'-sam.csc-sam.prd-sam.prd.slb.sfdc.net/#!/deployment/',Namespace,'/',Name,'?namespace=',Namespace) AS Url
    FROM k8s_resource
    WHERE ApiKind = 'Deployment'
) AS ss
WHERE
   ( Namespace != 'sam-watchdog' AND Namespace != 'sam-system' AND Namespace != 'csc-sam' AND Namespace NOT LIKE '%slb%') AND
   (availableReplicas != desiredReplicas OR availableReplicas IS NULL) AND
   (availability IS NULL OR availability < 0.6) AND
   (kpodsDown IS NULL OR kpodsDown >1) AND
   NOT ControlEstate LIKE 'prd-%' AND
   desiredReplicas > 1",
    },
  ],
}
