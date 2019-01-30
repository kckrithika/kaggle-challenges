{
      watchdogFrequency: "15m",
      name: "Sql95thPctPRLatencyOverLast24Hr",
      sql: "SELECT 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate,
'sql.95thPctPRLatencyOverLast24Hr' as Metric, IFNULL(latency,0) as Value,'' as Tags FROM
     ( SELECT
         prLatency.*,
         @row_num :=@row_num + 1 AS row_num
    FROM
        (   
         SELECT *
                FROM (  
         SELECT 
              prs.pr_num, 
              GREATEST(
              max(TIMESTAMPDIFF(SECOND,prs.most_recent_authorized_time, STR_TO_DATE( 
              CASE 
                        WHEN payload -> '$.status.startTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() 
                        ELSE JSON_UNQUOTE(payload -> '$.status.startTime') 
              END,'%Y-%m-%dT%H:%i:%s' ))) ,
               max(TIMESTAMPDIFF(SECOND,prs.most_recent_authorized_time, STR_TO_DATE( 
              CASE 
                        WHEN payload -> '$.status.maxImageEndTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() 
                        ELSE JSON_UNQUOTE(payload -> '$.status.maxImageEndTime') 
              END,'%Y-%m-%dT%H:%i:%s' ))) 
              ) latency
        FROM PullRequests prs 
        INNER JOIN PullRequestToTeamOrUser pApp ON prs.`pr_num` = pApp.`pr_num`
        LEFT JOIN 
          (   
                 SELECT * 
                 FROM   crd_history 
                 WHERE  apikind = 'Bundle') crds 
                 ON  crds.prnum = prs.pr_num WHERE state ='merged' 
                 AND `merged_time` > now() - INTERVAL 24 hour
                 GROUP BY prs.pr_num 
      ) nullPrLatency
       WHERE latency IS NOT NULL
       )prLatency,
     (SELECT @row_num:=0) counter ORDER BY prLatency.latency
     )   
    temp WHERE temp.row_num = ROUND (.95* @row_num);",

    }

