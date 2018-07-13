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
               ( Namespace != 'sam-watchdog' AND Namespace != 'sam-system' AND Namespace != 'csc-sam' AND Namespace NOT LIKE '%slb%') AND
               (availableReplicas != desiredReplicas OR availableReplicas IS NULL) AND
               (availability IS NULL OR availability < 0.6) AND
               (kpodsDown IS NULL OR kpodsDown >1) AND
               NOT ControlEstate LIKE 'prd-%' AND
               desiredReplicas > 1",
    },
    {
        name: "SqlSlaNode",
        instructions: "The following minion pools have multiple nodes down in Production requiring immediate attention according to our SLA. Debug Instructions: https://git.soma.salesforce.com/sam/sam/wiki/Repair-Failed-SAM-Host",
        alertThreshold: "10m",
        alertFrequency: "24h",
        watchdogFrequency: "10m",
        alertProfile: "sam",
        alertAction: "pagerDuty",
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
                        KINGDOM != 'PRD'
                        AND minionpool NOT LIKE '%ceph%'
                  GROUP BY minionpool
              ) ss
              ) ss2
              WHERE (TotalCount < 10 AND NotReadyCount >=2) OR (TotalCount >= 10 AND NotReadyPerc >=0.2)",
        },
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

    {
     name: "Sql95thPRLatency",
      instructions: "95th percentile of PRLatency is greater than 45 minutes",
      alertThreshold: "10m",
      alertFrequency: "24h",
      watchdogFrequency: "24h",
      alertProfile: "sam",
      alertAction: "email",
    sql: "SELECT *
    FROM
    ( SELECT * FROM
     ( SELECT
         prLatency.*,
         @row_num :=@row_num + 1 AS row_num
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
    ) prLatency ,
     (SELECT @row_num:=0) counter ORDER BY prLatency.latency
     )
    temp WHERE temp.row_num = ROUND (.95* @row_num)
    )
    temp2 WHERE temp2.latency > 45",
    },

    {
      name: "SqlPRAuthroizationLinkPostTimeLatency",
      instructions: "Following PRs don't have authorization link after 6 minutes of getting created.",
      alertThreshold: "10m",
      alertFrequency: "24h",
      watchdogFrequency: "10m",
      alertProfile: "sam",
      alertAction: "email",
      sql: "SELECT
          * 
        FROM (SELECT 
            pr_num,
            TIMESTAMPDIFF(MINUTE, CASE WHEN first_approval_link_posted_time IS NULL THEN now() ELSE first_approval_link_posted_time END, created_at) latency,
            first_approval_link_posted_time,
            created_at
        FROM PullRequests 
        WHERE created_at IS NOT NULL AND state ='open') noApprovalLink
        WHERE noApprovalLink.latency > 6 AND pr_num > 1000
        ORDER BY latency desc",
    },
    {
      name: "SqlPRFailtedToRunEvalPR",
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
          created_at,
          evaluate_pr_status,
          authorized_by,
          most_recent_authorized_time,
          TIMESTAMPDIFF(MINUTE, most_recent_authorized_time, now()) latency
        FROM PullRequests
        WHERE created_at IS NOT NULL AND authorized_by IS NOT NULL AND authorized_by !='' AND (`evaluate_pr_status` IS NULL OR evaluate_pr_status = 'unknown') AND most_recent_authorized_time IS NOT NULL
            AND state ='open'
        ) authedButUnkwn
        WHERE authedButUnkwn.latency > 30 AND pr_num > 1000",
    },

  ],
}
