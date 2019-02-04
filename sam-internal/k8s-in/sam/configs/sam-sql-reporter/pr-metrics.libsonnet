{
            name: "PR metrics",
            multisql: [
                {
                    name: "Manifest zip latency",
                    sql: "SELECT
             *
            FROM
            (SELECT
              p.pr_num,
              t.manifest_zip_time,
              p.merged_time,
              TIMESTAMPDIFF(MINUTE, merged_time, CASE WHEN t.manifest_zip_time IS NULL THEN now() ELSE t.manifest_zip_time END) latencyMin
            FROM PullRequests p
            LEFT OUTER JOIN TNRPManifestData t
            ON p.git_hash = t.git_hash
            WHERE p.state ='merged'   AND p.`merged_time` > NOW() - INTERVAL 10 DAY
            ) manifestZip
            ORDER BY `merged_time` desc
            LIMIT 10",
                },

#===================

                {
                    name: "Artifactory latency",
                    sql: "SELECT 
                *    
            FROM 
                (    
                SELECT  
                    prs.pr_num,
                    crds.PoolName,
                    crds.ControlEstate,
                    crds.payload -> '$.status.maxImageEndTime' maxImageEndTime,
                    crds.payload -> '$.status.startTime' startTime,
                    GREATEST(0,	TIMESTAMPDIFF(
                    		MINUTE, 
                    		STR_TO_DATE( 
        					JSON_UNQUOTE(payload -> '$.status.startTime'),
        					'%Y-%m-%dT%H:%i:%s' ), 
                    		STR_TO_DATE( 
          					CASE 
                   				WHEN payload -> '$.status.maxImageEndTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() 
                    		ELSE JSON_UNQUOTE(payload -> '$.status.maxImageEndTime') 
          					END,
          					'%Y-%m-%dT%H:%i:%s' ))) latencyMin
            FROM 
                PullRequests prs
            LEFT  JOIN  
                    (    
                    SELECT * 
                    FROM 
                    crd_history 
                    WHERE ApiKind = 'Bundle') crds 
                ON crds.PRNum = prs.pr_num 
                         WHERE prs.`state`='merged' AND  prs.merged_time > now() - INTERVAL 10 DAY
             ORDER BY prs.merged_time DESC
            ) imageLatency
            LIMIT 10",
                },

#===================

                {
                  name: "End to end latency",
                  sql: "SELECT
                           *
                        FROM
                            (
                            SELECT
                                prs.pr_num,
                                prs.most_recent_authorized_time,
                                payload -> '$.status.endTime' endTime,
                                crds.PoolName,
                                crds.ControlEstate,
                                TIMESTAMPDIFF(MINUTE,prs.most_recent_authorized_time, STR_TO_DATE( CASE 
                                    WHEN payload -> '$.status.endTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() 
                                    ELSE JSON_UNQUOTE(payload -> '$.status.endTime')
                                    END ,'%Y-%m-%dT%H:%i:%s' )) latencyMin
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
                        ORDER BY prs.`merged_time` DESC
                        ) prLatency
                        LIMIT 10",
                    },

#===================

                    {
                        name: "PR latency in seconds",
                        sql: "SELECT pr_num, 
       totallatencysec - (imagelatencysec + tnrplatency + evalPrLatency) samlatencysec,
       imagelatencysec artifactoryLatency,
       tnrplatency,
       totallatencysec e2eLatency,
       evalPrLatency
FROM   ( 
                       SELECT          pr_num, 
                                       imagelatencysec, 
                                       totallatencysec, 
                                       Timestampdiff(second, merged_time, 
                                       CASE 
                                                       WHEN t.manifest_zip_time IS NULL THEN Now()
                                                       ELSE t.manifest_zip_time 
                                       END) AS tnrplatency,
                                       evalPrLatency,
                                       merged_time
                       FROM            ( 
                                                 SELECT    prs.pr_num, 
                                                           prs.git_hash, 
                                                           prs.merged_time, 
                                                           Max(Timestampdiff(second, Str_to_date(Json_unquote(payload -> '$.status.startTime'),'%Y-%m-%dT%H:%i:%s'), Str_to_date( 
                                                           CASE 
                                                                     WHEN payload -> '$.status.maxImageEndTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() 
                                                                     ELSE Json_unquote(payload -> '$.status.maxImageEndTime') 
                                                           END,'%Y-%m-%dT%H:%i:%s'))) imagelatencysec, 
                                                           Max(Timestampdiff(second, prs.most_recent_authorized_time, Str_to_date(
                                                           CASE 
                                                                     WHEN payload -> '$.status.endTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() 
                                                                     ELSE Json_unquote(payload -> '$.status.endTime') 
                                                           END, '%Y-%m-%dT%H:%i:%s'))) totallatencysec,
                                                           Timestampdiff(second, prs.`most_recent_authorized_time`, prs.`most_recent_evaluate_pr_completion_time`) evalPrLatency
                                                 FROM      PullRequests prs 
                                                 INNER JOIN PullRequestToTeamOrUser pApp ON prs.`pr_num` = pApp.`pr_num`
                                                 LEFT JOIN 
                                                           ( 
                                                                  SELECT * 
                                                                  FROM   crd_history 
                                                                  WHERE  apikind = 'Bundle') crds
                                                 ON        crds.prnum = prs.pr_num 
                                                 WHERE     prs.state = 'merged' 
                                                 AND       prs.merged_time > Now() - interval 10 DAY
                                                 GROUP BY  prs.pr_num) sam 
                       LEFT OUTER JOIN TNRPManifestData t 
                       ON              sam.git_hash = t.git_hash )sam
                       ORDER BY merged_time desc
                       LIMIT 10",
                    },
                    {
                        name: "PR latency in seconds Non-null",
                        sql: "SELECT pr_num, 
       totallatencysec - (imagelatencysec + tnrplatency + evalPrLatency) samlatencysec,
       imagelatencysec artifactoryLatency,
       tnrplatency,
       totallatencysec e2eLatency,
       evalPrLatency
FROM   (   
                       SELECT          pr_num, 
                                       imagelatencysec, 
                                       GREATEST(totallatencysec1, totallatencysec2) totallatencysec, 
                                       Timestampdiff(second, merged_time, 
                                       LEAST(t.manifest_zip_time, startTime)) AS tnrplatency,
                                       evalPrLatency,
                                       merged_time
                       FROM            (   
                                                 SELECT    prs.pr_num, 
                                                           prs.git_hash, 
                                                           prs.merged_time, 
                                                           Max(Timestampdiff(second, Str_to_date(Json_unquote(payload -> '$.status.startTime'),'%Y-%m-%dT%H:%i:%s'), Str_to_date( 
                                                           CASE 
                                                                     WHEN payload -> '$.status.maxImageEndTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() 
                                                                     ELSE Json_unquote(payload -> '$.status.maxImageEndTime') 
                                                           END,'%Y-%m-%dT%H:%i:%s'))) imagelatencysec,
                                                           Max(Timestampdiff(second, prs.most_recent_authorized_time, Str_to_date(
                                                           CASE
                                                                     WHEN payload -> '$.status.startTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP()                                               
                                                                     ELSE Json_unquote(payload -> '$.status.startTime')
                                                           END, '%Y-%m-%dT%H:%i:%s'))) totallatencysec1,
                                                           Max(Timestampdiff(second, prs.most_recent_authorized_time, Str_to_date(
                                                           CASE
                                                                     WHEN payload -> '$.status.maxImageEndTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP()                                               
                                                                     ELSE Json_unquote(payload -> '$.status.maxImageEndTime')
                                                           END, '%Y-%m-%dT%H:%i:%s'))) totallatencysec2,
                                                           Timestampdiff(second, prs.`most_recent_authorized_time`, prs.`most_recent_evaluate_pr_completion_time`) evalPrLatency              ,
                                                           Max(Str_to_date(
                                                           CASE
                                                                     WHEN payload -> '$.status.startTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP()                                               
                                                                     ELSE Json_unquote(payload -> '$.status.startTime')
                                                           END, '%Y-%m-%dT%H:%i:%s')) startTime
                                                 FROM      PullRequests prs
                                                 INNER JOIN PullRequestToTeamOrUser pApp ON prs.`pr_num` = pApp.`pr_num`
                                                 LEFT JOIN 
                                                           ( 
                                                                  SELECT *
                                                                  FROM   crd_history
                                                                  WHERE  apikind = 'Bundle') crds
                                                 ON        crds.prnum = prs.pr_num 
         
                                                 WHERE     prs.state = 'merged'
                                                 AND       prs.merged_time > Now() - INTERVAL 1 DAY
                                                 GROUP BY  prs.pr_num) sam
                       LEFT OUTER JOIN TNRPManifestData t
                       ON              sam.git_hash = t.git_hash )sam
                       WHERE totallatencysec IS NOT NULL
                       ORDER BY totallatencysec DESC",
                    },
                    {
                        name: "E2E PR latency 95th, 90th, 75th, 50th Pct in minutes over last 24 hrs",
                        sql: "SELECT * from(
                                 SELECT
                                         prLatency.*,
                                         @row_num :=@row_num + 1 AS row_num
                                    FROM
                                        (   
                                        SELECT *
                                        FROM (   
                                       SELECT 
                                          prs.pr_num, 
                                          GREATEST(
                                          max(TIMESTAMPDIFF(minute,prs.most_recent_authorized_time, STR_TO_DATE( 
                                          CASE 
                                                    WHEN payload -> '$.status.startTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() 
                                                    ELSE JSON_UNQUOTE(payload -> '$.status.startTime') 
                                          END,'%Y-%m-%dT%H:%i:%s' ))) ,
                                           max(TIMESTAMPDIFF(minute,prs.most_recent_authorized_time, STR_TO_DATE( 
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
                                                 AND `merged_time` > now() - INTERVAL 1 DAY 
                                                 GROUP BY prs.pr_num 
                                      )nullPrLatency
                                      WHERE latency IS NOT NULL
                                      )prLatency
                                  ,   
                                     (SELECT @row_num:=0) counter ORDER BY prLatency.latency )    
                                    temp WHERE temp.row_num = ROUND (.95* @row_num) OR temp.row_num = ROUND (.90* @row_num) OR temp.row_num = ROUND (.75* @row_num) OR temp.row_num = ROUND (.50* @row_num)
                                    order by row_num desc",
                    },
                    {
                        name: "E2E PR latency 95th, 90th, 75th, 50th Pct in minutes for last 7 days",
                        sql: "SELECT * from(
                                 SELECT
                                         prLatency.*,
                                         @row_num :=@row_num + 1 AS row_num
                                    FROM
                                        (   
                                        SELECT *
                                        FROM (   
                                       SELECT 
                                          prs.pr_num, 
                                          GREATEST(
                                          max(TIMESTAMPDIFF(minute,prs.most_recent_authorized_time, STR_TO_DATE( 
                                          CASE 
                                                    WHEN payload -> '$.status.startTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() 
                                                    ELSE JSON_UNQUOTE(payload -> '$.status.startTime') 
                                          END,'%Y-%m-%dT%H:%i:%s' ))) ,
                                           max(TIMESTAMPDIFF(minute,prs.most_recent_authorized_time, STR_TO_DATE( 
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
                                                 AND `merged_time` > now() - INTERVAL 7 DAY 
                                                 GROUP BY prs.pr_num 
                                      )nullPrLatency
                                      WHERE latency IS NOT NULL
                                      )prLatency
                                  ,   
                                     (SELECT @row_num:=0) counter ORDER BY prLatency.latency )    
                                    temp WHERE temp.row_num = ROUND (.95* @row_num) OR temp.row_num = ROUND (.90* @row_num) OR temp.row_num = ROUND (.75* @row_num) OR temp.row_num = ROUND (.50* @row_num)
                                    order by row_num desc",
                    },

            ],
    }
