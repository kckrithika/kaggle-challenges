{
  sql_alerts: [
    {
      name: "Customer-Production-Deployment-SLA",
      instructions: "The following deployments are reported as bad customer deployments in Production. Debug Instructions: https://git.soma.salesforce.com/sam/sam/wiki/Debug-Failed-Deployment",
      alertThreshold: "10m",
      alertFrequency: "24h",
      watchdogFrequency: "10m",
      sql: "SELECT * FROM
(
  SELECT
    ControlEstate,
    Namespace,
    Name,
    JSON_EXTRACT(Payload, '$.metadata.annotations.\"smb.sam.data.sfdc.net/emailTo\"') AS email,
    CASE WHEN JSON_EXTRACT(Payload, '$.metadata.labels.sam_app') is NULL then False
         ELSE True END AS IsSamApp,
    JSON_EXTRACT(Payload, '$.spec.replicas') AS desiredReplicas,
    JSON_EXTRACT(Payload, '$.status.availableReplicas') AS availableReplicas,
    JSON_EXTRACT(Payload, '$.status.updatedReplicas') AS updatedReplicas,
    (JSON_EXTRACT(Payload, '$.spec.replicas') - JSON_EXTRACT(Payload, '$.status.availableReplicas')) AS kpodsDown,
    COALESCE(JSON_EXTRACT(Payload, '$.status.availableReplicas') /nullif(JSON_EXTRACT(Payload, '$.spec.replicas'), 0), 0) AS availability,
    0.6 as minAvailability,
    CONCAT('http://dashboard-',SUBSTR(ControlEstate, 1, 3),'-sam.csc-sam.prd-sam.prd.slb.sfdc.net/#!/deployment/',Namespace,'/',Name,'?namespace=',Namespace) AS Url
    FROM k8s_resource
    WHERE ApiKind = 'Deployment'
) AS ss
WHERE
   isSamApp AND
   ( Namespace != 'sam-watchdog' AND Namespace != 'sam-system' AND Namespace != 'csc-sam' AND Namespace NOT LIKE '%slb%') AND
   (availableReplicas != desiredReplicas OR availableReplicas IS NULL) AND
   (availability IS NULL OR availability < 0.6) AND
   (kpodsDown IS NULL OR kpodsDown >1) AND
   NOT ControlEstate LIKE 'prd-%' AND
   desiredReplicas > 1",
    },
    {
        name: "Customer-Node_SLA",
        instructions: "The following minion pools have multiple nodes down in Production requiring immediate attention according to our SLA. Debug Instructions: https://git.soma.salesforce.com/sam/sam/wiki/Repair-Failed-SAM-Host",
        alertThreshold: "10m",
        alertFrequency: "24h",
        watchdogFrequency: "10m",
        sql: "SELECT
              	minionpool,
              	TotalCount,
              	NotReadyCount,
              	NotReadyPerc
              FROM
              (
              SELECT
                      minionpool,
                      TotalCount ,
                      NotReadyCount,
                      (NotReadyCount/TotalCount) as 'NotReadyPerc'

              FROM
              (
                  SELECT
                        COUNT(*) as TotalCount,
                        SUM(CASE WHEN READY != 'True' THEN 1 ELSE 0 END) as NotReadyCount,
                        minionpool
                  FROM
                        nodeDetailView
                  WHERE
                        KINGDOM != 'PRD'
                        AND minionpool NOT LIKE '%ceph%'
                  GROUP BY minionpool
              ) ss
              ) ss2
              WHERE (TotalCount < 10 AND NotReadyCount >=2) OR (TotalCount >= 10 AND NotReadyPerc >=0.2)",
        },
  ],
}
