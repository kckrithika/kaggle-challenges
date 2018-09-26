{
  sql_alerts: [
    {
      name: "SqlSlaDepl",
      instructions: "The following deployments are reported as bad customer deployments in Production. Debug Instructions: https://git.soma.salesforce.com/sam/sam/wiki/Debug-Failed-Deployment",
      alertThreshold: "10m",
      alertFrequency: "24h",
      watchdogFrequency: "10m",
      alertProfile: "sam",
      alertAction: "pagerduty",
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
                           ( Namespace != 'sam-watchdog' AND Namespace != 'sam-system' AND Namespace != 'csc-sam' AND Namespace NOT LIKE '%slb%' AND Namespace NOT LIKE '%user%' 
                           " + "AND Namespace NOT LIKE '%cloudatlas%'" +  # Follow up work item W-5415695
                           ") AND
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
        alertAction: "pagerduty",
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
                        AND minionpool NOT LIKE '%slb%'
                        AND minionpool NOT LIKE '%storage%'
                  GROUP BY minionpool
              ) ss
              ) ss2
              WHERE "
              # cdebains is responsible for changing this back
              + "(TotalCount < 10 AND NotReadyCount >=2 AND minionpool like 'par-sam' AND NotReadyPerc >=0.5) 
              OR (TotalCount < 10 AND NotReadyCount >=2 AND minionpool not like 'par-sam')

              OR (TotalCount >= 10 AND NotReadyPerc >=0.2)",
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
      instructions: "Following PRs have failed to get deployed within 45 minutes of getting authorized.",
      alertThreshold: "10m",
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
        TIMESTAMPDIFF(MINUTE,prs.most_recent_authorized_time, STR_TO_DATE( 
            JSON_UNQUOTE(payload -> '$.status.endTime'),'%Y-%m-%dT%H:%i:%s' )) latency
FROM
    PullRequests prs 
LEFT  JOIN
        (   
        SELECT *
        FROM
        crd_history
        WHERE ApiKind = 'Bundle') crds
    ON crds.PRNum = prs.pr_num
WHERE  prs.merged_time > now() - INTERVAL 24 hour
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
      alertAction: "pagerDuty",
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
      alertAction: "pagerDuty",
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
        WHERE created_time IS NOT NULL AND created_time  > NOW() - Interval 10 day AND authorized_by IS NOT NULL AND authorized_by !='' AND (`evaluate_pr_status` IS NULL OR evaluate_pr_status = 'unknown') AND most_recent_authorized_time IS NOT NULL
            AND state ='open'
        ) authedButUnkwn
        WHERE authedButUnkwn.latency > 30",
    },

# =====

    {
      name: "SqlPRFailedToProduceManifestZip",
      instructions: "Following PRs have failed to produce corresponding manifest.zip file after 30 minutes of getting  merged.",
      alertThreshold: "10m",
      alertFrequency: "24h",
      watchdogFrequency: "10m",
      alertProfile: "sam",
      alertAction: "pagerDuty",
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
      instructions: "Following PRs have at least one image that's not available after 20 minutes of starting deployment",
      alertThreshold: "0m",
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
                    payload -> '$.status.startTime',
                    payload -> '$.status.maxImageEndTime',
                    TIMESTAMPDIFF(MINUTE, 
                    		STR_TO_DATE(JSON_UNQUOTE(payload -> '$.status.startTime'),'%Y-%m-%dT%H:%i:%s'), 
                    		STR_TO_DATE( CASE 
                    						WHEN payload -> '$.status.maxImageEndTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() 
                    						ELSE JSON_UNQUOTE(payload -> '$.status.maxImageEndTime') 
                    						END,
                    					'%Y-%m-%dT%H:%i:%s')) latencyMin
            FROM
                PullRequests prs
            LEFT  JOIN
                    (
                    SELECT *
                    FROM
                    crd_history
                    WHERE ApiKind = 'Bundle') crds
                ON crds.PRNum = prs.pr_num
                WHERE  prs.merged_time > now() - INTERVAL 10 DAY
            ORDER BY prs.merged_time desc
            ) imageLatency
            WHERE  latencyMin > 20",
    },


  ],


#### ARGUS METRICS ####

   argus_metrics: [
   {
     watchdogFrequency: "15m",
     name: "MachineCountByKernelVersion",
     sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate, 'sql.machineCountByKernelVersion' as Metric, COUNT(*) as Value, CONCAT('KernelVersion=',KernelVersion) as Tags from nodeDetailView group by kernelVersion",
   },

# =====

   {
     watchdogFrequency: "15m",
     name: "MachineCountByKingdomAndKernelVersion",
     sql: "select UPPER(kingdom) as Kingdom, 'NONE' as SuperPod, ControlEstate as Estate, 'sql.machineCountByKingdomAndKernelVersion' as Metric, COUNT(*) as Value, CONCAT('KernelVersion=',KernelVersion) as Tags from nodeDetailView group by ControlEstate, kingdom, kernelVersion",
   },

# =====

   {
     watchdogFrequency: "1m",
     name: "MySqlSystemMetrics",
     sql: "SELECT 'PRD' as Kingdom, 'NONE' as SuperPod, 'prd-sam' as Estate, Metric, Value, '' as Tags FROM (SELECT CONCAT(\"mysql_metrics_\", Variable_name) as Metric, Variable_value as Value from sys.metrics where Variable_name in ('aborted_connects', 'bytes_received', 'bytes_sent', 'connections', 'connection_errors_select', 'created_tmp_files', 'innodb_buffer_pool_pages_dirty', 'innodb_buffer_pool_pages_data', 'innodb_buffer_pool_pages_free', 'innodb_data_pending_writes', 'innodb_row_lock_current_waits', 'innodb_row_lock_time_avg', 'queries', 'table_open_cache_hits', 'table_open_cache_misses', 'uptime') UNION SELECT CONCAT(\"mysql_metrics_events_avg_latency_\", REPLACE(events,\"/\",\"_\")) as Metric, avg_latency as Variable_value from sys.x$waits_global_by_latency UNION SELECT CONCAT(\"mysql_metrics_user_summary_by_statement_type_\", user, \"_\", statement), total as Variable_value from sys.x$user_summary_by_statement_type UNION SELECT CONCAT(\"mysql_metrics_schema_table_statistics_fetch_count_\", table_schema, \"_\", table_name) as Variable_name, rows_fetched as Variable_value from sys.x$schema_table_statistics  UNION (SELECT CONCAT(\"mysql_metrics_schema_table_statistics_fetch_avg_latency_\", table_schema, \"_\", table_name) as Variable_name, fetch_latency / rows_fetched as Variable_value from sys.x$schema_table_statistics) UNION SELECT CONCAT(\"mysql_metrics_schema_table_statistics_insert_count_\", table_schema, \"_\", table_name) as Variable_name, rows_inserted as Variable_value from sys.x$schema_table_statistics UNION (SELECT CONCAT(\"mysql_metrics_schema_table_statistics_insert_avg_latency_\", table_schema, \"_\", table_name) as Variable_name, insert_latency / rows_inserted as Variable_value from sys.x$schema_table_statistics) UNION SELECT CONCAT(\"mysql_metrics_schema_table_statistics_update_count_\", table_schema, \"_\", table_name) as Variable_name, rows_updated as Variable_value from sys.x$schema_table_statistics UNION (SELECT CONCAT(\"mysql_metrics_schema_table_statistics_update_avg_latency_\", table_schema, \"_\", table_name) as Variable_name, update_latency / rows_updated as Variable_value from sys.x$schema_table_statistics)) a where a.Value IS NOT NULL;",
   },

# =====

   {
     watchdogFrequency: "15m",
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

# ====

  {
    watchdogFrequency: "15m",
    name: "WatchdogSuccessCount",
    sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate, 
'sql.checkerFailCount' as Metric, FailureCount as Value, CONCAT('CheckerName=',CheckerName) as Tags
from (
  select
    CheckerName,
    SUM(FailureCount) as FailureCount
  from
  (
    select
      Payload->>'$.status.report.CheckerName' as CheckerName,
      case when Payload->>'$.status.report.Success' = 'false' then 1 else 0 end as FailureCount
    from k8s_resource
    where ApiKind = 'WatchDog'
  ) as ss
  where CheckerName not like 'Sql%' and CheckerName not like 'MachineCount%'
  group by CheckerName
) as ss2
union all
select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate, 
'sql.checkerSuccessCount' as Metric, SuccessCount as Value, CONCAT('CheckerName=',CheckerName) as Tags
from (
  select
    CheckerName,
    SUM(SuccessCount) as SuccessCount
  from
  (
    select
      Payload->>'$.status.report.CheckerName' as CheckerName,
      case when Payload->>'$.status.report.Success' = 'true' then 1 else 0 end as SuccessCount
    from k8s_resource
    where ApiKind = 'WatchDog'
  ) as ss3
  where CheckerName not like 'Sql%' and CheckerName not like 'MachineCount%'
  group by CheckerName
) as ss4",
  },

# ====

  {
     watchdogFrequency: "15m",
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

# =====

   {
     watchdogFrequency: "15m",
     name: "SqlNodeReadyCount",
     sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate, 'sql.nodeCountByStatus' as Metric, CONCAT('Ready=',Ready) as Tags, Count as Value
from (
  select Ready, Count(*) as Count
  from nodeDetailView
  group by Ready
) as ss
union all
select UPPER(kingdom) as Kingdom, 'NONE' as SuperPod, ControlEstate as Estate, 'sql.sql.nodeCountByStatusPerKingdom' as Metric, CONCAT('Ready=',Ready) as Tags, Count as Value
from (
  select kingdom, ControlEstate, Ready, Count(*) as Count
  from nodeDetailView
  group by kingdom, ControlEstate, Ready
) as ss2",
   },

# =====

   {
      watchdogFrequency: "15m",
      name: "Sql95thPctPRLatencyOverLast24Hr",
      sql: "SELECT 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate,
'sql.95thPctPRLatencyOverLast24Hr' as Metric, latency as Value,'' as Tags FROM
     ( SELECT
         prLatency.*,
         @row_num :=@row_num + 1 AS row_num
    FROM
        (
       SELECT    
          prs.pr_num, 
          max(TIMESTAMPDIFF(minute,prs.most_recent_authorized_time, STR_TO_DATE( 
          CASE 
                    WHEN payload -> '$.status.endTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() 
                    ELSE JSON_UNQUOTE(payload -> '$.status.endTime') 
          END,'%Y-%m-%dT%H:%i:%s' ))) latency 
        FROM PullRequests prs 
        LEFT JOIN 
          ( 
                 SELECT * 
                 FROM   crd_history 
                 WHERE  apikind = 'Bundle') crds 
                 ON  crds.prnum = prs.pr_num WHERE state ='merged' 
                 AND `merged_time` > now() - INTERVAL 24 hour
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
'sql.95thPctPRImageLatencyOverLast24Hr' as Metric, latencyMin as Value, '' as Tags FROM
     ( SELECT
         imageLatency.*,
         @row_num :=@row_num + 1 AS row_num
    FROM
        (       
                SELECT  
                    prs.pr_num,
                    MAX(TIMESTAMPDIFF(MINUTE, STR_TO_DATE(JSON_UNQUOTE(payload -> '$.status.startTime'),'%Y-%m-%dT%H:%i:%s'), STR_TO_DATE( CASE WHEN payload -> '$.status.maxImageEndTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() ELSE  JSON_UNQUOTE(payload -> '$.status.maxImageEndTime') END, '%Y-%m-%dT%H:%i:%s'))) latencyMin
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
'sql.95thPctPRTNRPLatencyOverLast24Hr' as Metric, latency as Value, '' as Tags FROM
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

# ====

# ====

   {
      watchdogFrequency: "15m",
      name: "Sql95thPctPRSamLatencyOverLast24Hr",
      sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate,
'sql.95thPctPRSamLatencyOverLast24Hr' as Metric, samlatencymin as Value, '' as Tags FROM   (  
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
                                                                                           Max(Timestampdiff(minute, STR_TO_DATE(JSON_UNQUOTE(payload -> '$.status.startTime'),'%Y-%m-%dT%H:%i:%s'), 
                                                                                           		STR_TO_DATE(
                                                                                           CASE
                                                                                                     WHEN payload -> '$.status.maxImageEndTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP()
                                                                                                     ELSE JSON_UNQUOTE(payload -> '$.status.maxImageEndTime')
                                                                                           END,'%Y-%m-%dT%H:%i:%s'))) imagelatencymin,
                                                                                           Max(Timestampdiff(minute, prs.most_recent_authorized_time,
                                                                                           STR_TO_DATE( CASE
                                                                                                     WHEN payload -> '$.status.endTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP()
                                                                                                     ELSE JSON_UNQUOTE(payload -> '$.status.endTime')
                                                                                           END, '%Y-%m-%dT%H:%i:%s'))) totallatencymin
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
    {
      name: "KubednsPodCount",
      alertThreshold: "3m",
      alertFrequency: "24h",
      watchdogFrequency: "1m",
      alertProfile: "sam",
      alertAction: "email",
      sql: "SELECT
              controlEstate,
              Running,
              NotRunning
            FROM
            (
            SELECT
              controlEstate,
              SUM(Running) as Running,
              SUM(NotRunning) as NotRunning
            FROM
            (
            SELECT
              controlEstate,
              (CASE WHEN Phase = 'Running' then 1 else 0 end) as Running,
              (CASE WHEN Phase <> 'Running' then 1 else 0 end) as NotRunning
            FROM podDetailView
            WHERE namespace = 'kube-system'
            ) as ss
            GROUP BY controlEstate
            ORDER BY NotRunning desc
            ) as ss1
            WHERE
             Running < NotRunning",
    },
  ],

}
