{
      watchdogFrequency: "15m",
      name: "Sql95thPctPRImageLatencyOverLast24Hr",
      sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate,
'sql.95thPctPRImageLatencyOverLast24Hr' as Metric, IFNULL(latencySec, 0) as Value, '' as Tags FROM
     ( SELECT
         imageLatency.*,
         @row_num :=@row_num + 1 AS row_num
    FROM
        (    
              SELECT *
              FROM(
                SELECT  
                    prs.pr_num,
                    MAX(TIMESTAMPDIFF(SECOND, STR_TO_DATE(JSON_UNQUOTE(payload -> '$.status.startTime'),'%Y-%m-%dT%H:%i:%s'), STR_TO_DATE( CASE WHEN payload -> '$.status.maxImageEndTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() ELSE  JSON_UNQUOTE(payload -> '$.status.maxImageEndTime') END, '%Y-%m-%dT%H:%i:%s'))) latencySec
            FROM 
                PullRequests prs 
            INNER JOIN PullRequestToTeamOrUser pApp ON prs.`pr_num` = pApp.`pr_num`
            LEFT  JOIN
                    (   
                    SELECT *
                    FROM 
                    crd_history 
                    WHERE ApiKind = 'Bundle') crds
                ON crds.PRNum = prs.pr_num 
            WHERE prs.state ='merged' AND prs.merged_time > NOW() - INTERVAL 24 HOUR
            GROUP BY prs.pr_num
            ) imageLatencyNull
            where latencySec IS NOT NULL)
            imageLatency
            ,
     (SELECT @row_num:=0) counter ORDER BY imageLatency.latencySec
     )   
    temp  
    WHERE temp.row_num = ROUND (.95* @row_num)",
    }

