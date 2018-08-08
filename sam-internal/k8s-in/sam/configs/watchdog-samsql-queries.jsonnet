{
  sql_alerts: [
    {
      name: "SqlSlaDepl",
      instructions: "The following deployments are reported as bad customer deployments in Production. Debug Instructions: https://git.soma.salesforce.com/sam/sam/wiki/Debug-Failed-Deployment",
      alertThreshold: "10m",
      alertFrequency: "24h",
      watchdogFrequency: "10m",
      alertProfile: "sam",
      alertAction: "email",
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
                           ( Namespace != 'sam-watchdog' AND Namespace != 'sam-system' AND Namespace != 'csc-sam' AND Namespace NOT LIKE '%slb%' AND Namespace NOT LIKE '%user%') AND
                           (availableReplicas != desiredReplicas OR availableReplicas IS NULL) AND
                           (availability IS NULL OR availability < 0.6) AND
                           (kpodsDown IS NULL OR kpodsDown >1) AND
                           NOT ControlEstate LIKE 'prd-%' AND
                           ControlEstate != 'unknown' AND
                           desiredReplicas > 1",
    },

# =====

    {
        name: "SqlSlaNode",
        instructions: "The following minion pools have multiple nodes down in Production requiring immediate attention according to our SLA. Debug Instructions: https://git.soma.salesforce.com/sam/sam/wiki/Repair-Failed-SAM-Host",
        alertThreshold: "10m",
        alertFrequency: "24h",
        watchdogFrequency: "10m",
        alertProfile: "sam",
        alertAction: "email",
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
                        SUM(CASE WHEN READY = 'True' THEN 0 ELSE 1 END) as NotReadyCount,
                        minionpool
                  FROM
                        nodeDetailView
                  WHERE
                        KINGDOM != 'PRD' AND KINGDOM != 'UNK'
                        AND minionpool NOT LIKE '%ceph%'
                  GROUP BY minionpool
              ) ss
              ) ss2
              WHERE (TotalCount < 10 AND NotReadyCount >=2) OR (TotalCount >= 10 AND NotReadyPerc >=0.2)",
        },

# =====

    {
            name: "SqlSamControl",
            instructions: "The following SAM control stack components dont have even 1 healhty pod",
            alertThreshold: "10m",
            alertFrequency: "24h",
            watchdogFrequency: "10m",
            alertProfile: "sam",
            alertAction: "email",
            sql: "SELECT * FROM
                  (
                    SELECT
                      ControlEstate,
                      Namespace,
                      Name,
                      JSON_EXTRACT(Payload, '$.spec.replicas') AS desiredReplicas,
                      JSON_EXTRACT(Payload, '$.status.availableReplicas') AS availableReplicas,
                      JSON_EXTRACT(Payload, '$.status.updatedReplicas') AS updatedReplicas,
                      (JSON_EXTRACT(Payload, '$.spec.replicas') - JSON_EXTRACT(Payload, '$.status.availableReplicas')) AS kpodsDown,
                      COALESCE(JSON_EXTRACT(Payload, '$.status.availableReplicas') /nullif(JSON_EXTRACT(Payload, '$.spec.replicas'), 0), 0) AS availability,
                      CONCAT('http://dashboard-',SUBSTR(ControlEstate, 1, 3),'-sam.csc-sam.prd-sam.prd.slb.sfdc.net/#!/deployment/',Namespace,'/',Name,'?namespace=',Namespace) AS Url
                      FROM k8s_resource
                      WHERE ApiKind = 'Deployment'
                  ) AS ss
                  WHERE
                     Namespace = 'sam-system' AND
                     (availableReplicas < 1 OR availableReplicas IS NULL) AND
                     ControlEstate NOT LIKE '%sdc%' AND
                     ControlEstate NOT LIKE '%storage%' AND
                     ControlEstate NOT LIKE '%sdn%' AND
                     ControlEstate NOT LIKE '%slb%' AND
                     desiredReplicas != 0",
    },

# =====

    {
    name: "SqlPRLatency",
      instructions: "Following PRs have failed to get deployed within 45 minutes of getting merged.",
      alertThreshold: "10m",
      alertFrequency: "24h",
      watchdogFrequency: "10m",
      alertProfile: "sam",
      alertAction: "email",
      sql: "SELECT 
 	pr_num
FROM 
	(
	SELECT 	
   		prs.pr_num,
   		TIMESTAMPDIFF(MINUTE,prs.merged_time, CASE WHEN payload -> '$.status.endTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() ELSE payload -> '$.status.endTime' END  ) latency
FROM 
	PullRequests prs
LEFT  JOIN  
		(
		SELECT * 
		FROM 
		crd_history 
	 	WHERE ApiKind = 'Bundle') crds
	ON crds.PRNum = prs.pr_num
ORDER BY prs.pr_num 
) prLatency
WHERE latency > 45",
    },

# =====


# =====

    {
      name: "SqlPRAuthroizationLinkPostTimeLatency",
      instructions: "Following PRs don't have authorization link after 5 minutes of getting created.",
      alertThreshold: "10m",
      alertFrequency: "24h",
      watchdogFrequency: "10m",
      alertProfile: "sam",
      alertAction: "email",
      sql: "SELECT
          * 
        FROM (SELECT 
            pr_num,
            TIMESTAMPDIFF(MINUTE, created_time, CASE WHEN first_approval_link_posted_time IS NULL THEN now() ELSE first_approval_link_posted_time END) latency,
            first_approval_link_posted_time,
            created_time
        FROM PullRequests 
        WHERE created_time IS NOT NULL AND created_time > NOW() - Interval 10 day AND state ='open') noApprovalLinkInMin
        WHERE noApprovalLinkInMin.latency > 5
        ORDER BY latency desc",
    },

# =====

    {
      name: "SqlPRFailedToRunEvalPR",
      instructions: "Following PRs haven't run evaluatePR more than 30 mins after getting authorized.",
      alertThreshold: "10m",
      alertFrequency: "24h",
      watchdogFrequency: "10m",
      alertProfile: "sam",
      alertAction: "email",
      sql: "SELECT 
         *
        FROM
        (SELECT 
          pr_num,
          created_time,
          evaluate_pr_status,
          authorized_by,
          most_recent_authorized_time,
          TIMESTAMPDIFF(MINUTE,  most_recent_authorized_time, now()) latency
        FROM PullRequests
        WHERE created_time IS NOT NULL AND authorized_by IS NOT NULL AND authorized_by !='' AND (`evaluate_pr_status` IS NULL OR evaluate_pr_status = 'unknown') AND most_recent_authorized_time IS NOT NULL
            AND state ='open'
        ) authedButUnkwn
        WHERE authedButUnkwn.latency > 30 AND pr_num > 1000",
    },

# =====

    {
      name: "SqlPRFailedToProduceManifestZip",
      instructions: "Following PRs have failed to produce corresponding manifest.zip file after 30 minutes of getting  merged.",
      alertThreshold: "10m",
      alertFrequency: "24h",
      watchdogFrequency: "10m",
      alertProfile: "sam",
      alertAction: "email",
      sql: "SELECT
             *
            FROM
            (SELECT
              p.pr_num,
              t.manifest_zip_time,
              p.merged_time,
              TIMESTAMPDIFF(MINUTE, merged_time, CASE WHEN t.manifest_zip_time IS NULL THEN now() ELSE t.manifest_zip_time END) latency
            FROM PullRequests p
            LEFT OUTER JOIN TNRPManifestData t
            ON p.git_hash = t.git_hash
            WHERE p.state ='merged'   AND p.`merged_time` > NOW() - INTERVAL 10 DAY
            ) manifestZip
            WHERE manifestZip.latency > 30",
    },
    {
      name: "SqlPRImageUnavailable",
      instructions: "Following PRs have at least one image that's not available after 20 minutes of getting it merged",
      alertFrequency: "24h",
      watchdogFrequency: "10m",
      alertProfile: "sam",
      alertAction: "email",
      sql: "SELECT 
                *
            FROM 
                (
                SELECT 	
                    prs.pr_num,
                    crds.PoolName,
                    crds.ControlEstate,
                    TIMESTAMPDIFF(MINUTE, prs.merged_time, CASE WHEN payload -> '$.status.maxImageEndTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() ELSE payload -> '$.status.maxImageEndTime' END) latencyMin
            FROM 
                PullRequests prs
            LEFT  JOIN  
                    (
                    SELECT * 
                    FROM 
                    crd_history 
                    WHERE ApiKind = 'Bundle') crds
                ON crds.PRNum = prs.pr_num 
            ORDER BY prs.pr_num 
            ) imageLatency
            WHERE  latencyMin > 20",
    },


  ],


#### ARGUS METRICS ####

   argus_metrics: [
   {
     watchdogFrequency: "60m",
     name: "MachineCountByKernelVersion",
     sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate, 'sql.machineCountByKernelVersion' as Metric, COUNT(*) as Value, CONCAT('KernelVersion=',KernelVersion) as Tags from nodeDetailView group by kernelVersion",
   },

# =====

   {
     watchdogFrequency: "60m",
     name: "MachineCountByKingdomAndKernelVersion",
     sql: "select UPPER(kingdom) as Kingdom, 'NONE' as SuperPod, ControlEstate as Estate, 'sql.machineCountByKingdomAndKernelVersion' as Metric, COUNT(*) as Value, CONCAT('KernelVersion=',KernelVersion) as Tags from nodeDetailView group by ControlEstate, kingdom, kernelVersion",
   },

# =====

   {
     watchdogFrequency: "60m",
     name: "WatchdogSuccessPct",
     sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate, 
'sql.checkerPassPct' as Metric, SuccessPct as Value, CONCAT('CheckerName=',CheckerName) as Tags
from (
  select
    CheckerName,
    SUM(SuccessCount)/(SUM(SuccessCount)+SUM(FailureCount)) as SuccessPct
  from
  (
    select
      Payload->>'$.status.report.CheckerName' as CheckerName,
      case when Payload->>'$.status.report.Success' = 'true' then 1 else 0 end as SuccessCount,
      case when Payload->>'$.status.report.Success' = 'false' then 1 else 0 end as FailureCount
    from k8s_resource
    where ApiKind = 'WatchDog'
  ) as ss
  where CheckerName not like 'Sql%' and CheckerName not like 'MachineCount%'
  group by CheckerName
) as ss2",
  },
  {
     watchdogFrequency: "60m",
     name: "WatchdogSuccessPctByKingdom",
     sql: "select UPPER(kingdom) as Kingdom, 'NONE' as SuperPod, ControlEstate as Estate,
'sql.checkerPassPctPerKingdom' as Metric, SuccessPct as Value, CONCAT('CheckerName=',CheckerName) as Tags
from (
  select
    ControlEstate,
    Kingdom,
    CheckerName,
    SUM(SuccessCount)/(SUM(SuccessCount)+SUM(FailureCount)) as SuccessPct
  from
  (
    select
      substr(ControlEstate,1,3) AS Kingdom,
      ControlEstate,
      Payload->>'$.status.report.CheckerName' as CheckerName,
      case when Payload->>'$.status.report.Success' = 'true' then 1 else 0 end as SuccessCount,
      case when Payload->>'$.status.report.Success' = 'false' then 1 else 0 end as FailureCount
    from k8s_resource
    where ApiKind = 'WatchDog'
  ) as ss
  where CheckerName not like 'Sql%' and CheckerName not like 'MachineCount%'
  group by CheckerName, ControlEstate, Kingdom
) as ss2",
  },

# =====

   {
      watchdogFrequency: "15m",
      name: "Sql95thPctPRLatencyOverLast24Hr",
      sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate,
'sql.95thPctPRLatencyOverLast24Hr' as Metric, latency as Value FROM
     ( SELECT
         prLatency.*,
         @row_num :=@row_num + 1 AS row_num
    FROM
        (
        SELECT
            prs.pr_num,
            MAX(TIMESTAMPDIFF(MINUTE,prs.merged_time, CASE WHEN payload -> '$.status.endTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() ELSE payload -> '$.status.endTime' END  )) latency
    FROM
        PullRequests prs
    LEFT  JOIN
            (
            SELECT *
            FROM
            crd_history
            WHERE ApiKind = 'Bundle') crds
        ON crds.PRNum = prs.pr_num
    WHERE state ='merged' AND `merged_time` > NOW() - INTERVAL 24 HOUR
    GROUP BY prs.pr_num
    ) prLatency ,
     (SELECT @row_num:=0) counter ORDER BY prLatency.latency
     )
    temp WHERE temp.row_num = ROUND (.95* @row_num)",

    },


# =====


# =====

   {
      watchdogFrequency: "15m",
      name: "Sql95thPctPRImageLatencyOverLast24Hr",
      sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate,
'sql.95thPctPRImageLatencyOverLast24Hr' as Metric, latencyMin as Value FROM
     ( SELECT
         imageLatency.*,
         @row_num :=@row_num + 1 AS row_num
    FROM
        (
                SELECT 	
                    prs.pr_num,
                    MAX(TIMESTAMPDIFF(MINUTE, CASE WHEN payload -> '$.status.maxImageEndTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() ELSE payload -> '$.status.maxImageEndTime' END, prs.merged_time)) latencyMin
            FROM 
                PullRequests prs
            LEFT  JOIN  
                    (
                    SELECT * 
                    FROM 
                    crd_history 
                    WHERE ApiKind = 'Bundle') crds
                ON crds.PRNum = prs.pr_num 
           	WHERE prs.state ='merged' AND prs.merged_time > NOW() - INTERVAL 24 HOUR
    		GROUP BY prs.pr_num 
            ) imageLatency,
     (SELECT @row_num:=0) counter ORDER BY imageLatency.latencyMin
     )
    temp 
    WHERE temp.row_num = ROUND (.95* @row_num)",
    },


# =====

# =====

   {
      watchdogFrequency: "15m",
      name: "Sql95thPctPRTNRPLatencyOverLast24Hr",
      sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate,
'sql.95thPctPRTNRPLatencyOverLast24Hr' as Metric, latency as Value FROM
(
SELECT
         prLatency.*,
         @row_num :=@row_num + 1 AS row_num
FROM
(
SELECT
              p.pr_num,
              t.manifest_zip_time,
              p.merged_time,
              TIMESTAMPDIFF(MINUTE,  `merged_time`,CASE WHEN t.manifest_zip_time IS NULL THEN now() ELSE t.manifest_zip_time END) latency
            FROM PullRequests p
            LEFT OUTER JOIN TNRPManifestData t
            ON p.git_hash = t.git_hash
            WHERE p.state ='merged'   AND p.`merged_time` > NOW() - INTERVAL 24 HOUR            
)prLatency,
 (SELECT @row_num:=0) counter ORDER BY prLatency.latency
     )
    temp WHERE temp.row_num = ROUND (.95* @row_num)",
    },


# =====

# =====

   {
      watchdogFrequency: "15m",
      name: "Sql95thPctPRSamLatencyOverLast24Hr",
      sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate,
'sql.95thPctPRSamLatencyOverLast24Hr' as Metric, samlatencymin as Value FROM   ( 
              SELECT sam.*, 
                     @row_num := @row_num + 1 AS row_num 
              FROM   ( 
                              SELECT   pr_num, 
                                       totallatencymin - (imagelatencymin + tnrplatency) samlatencymin
                              FROM     ( 
                                                       SELECT          pr_num, 
                                                                       imagelatencymin, 
                                                                       totallatencymin, 
                                                                       Timestampdiff(minute, merged_time,
                                                                       CASE 
                                                                                       WHEN t.manifest_zip_time IS NULL THEN Now()
                                                                                       ELSE t.manifest_zip_time
                                                                       end) AS tnrplatency 
                                                       FROM            ( 
                                                                                 SELECT    prs.pr_num,
                                                                                           prs.git_hash,
                                                                                           prs.merged_time,
                                                                                           Max(Timestampdiff(minute,
                                                                                           CASE 
                                                                                                     WHEN payload -> '$.status.maxImageEndTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() 
                                                                                                     ELSE payload -> '$.status.maxImageEndTime' 
                                                                                           end, prs.merged_time)) imagelatencymin,
                                                                                           Max(Timestampdiff(minute, prs.merged_time,
                                                                                           CASE 
                                                                                                     WHEN payload -> '$.status.endTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() 
                                                                                                     ELSE payload -> '$.status.endTime' 
                                                                                           end)) totallatencymin
                                                                                 FROM      PullRequests prs
                                                                                 LEFT JOIN 
                                                                                           ( 
                                                                                                  SELECT *
                                                                                                  FROM   crd_history
                                                                                                  WHERE  apikind = 'Bundle') crds
                                                                                 ON        crds.prnum = prs.pr_num
                                                                                 WHERE     prs.state = 'merged'
                                                                                 AND       prs.merged_time > Now() - INTERVAL 24 hour
                                                                                 GROUP BY  prs.pr_num) sam
                                                       LEFT OUTER JOIN TNRPManifestData t 
                                                       ON              sam.git_hash = t.git_hash )sam2)sam,
                                       ( SELECT @row_num := 0) counter ORDER BY samlatencymin ) temp
              WHERE  temp.row_num = Round (.95 * @row_num)",
    },


# =====

  ],

}
