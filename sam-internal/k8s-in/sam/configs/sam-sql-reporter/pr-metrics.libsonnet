{
            name: "PR metrics",
            multisql: [
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
                        name: "E2E PR latency 95th, 90th, 75th, 50th Pct in seconds over last 24 hrs",
                        sql: " select latency, percentile
 from (
 select *,
 		 @rank :=@rank+ 1 AS rank

  from(       
 SELECT  * 
         from(
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
                                          max(TIMESTAMPDIFF(second,prs.most_recent_authorized_time, STR_TO_DATE( 
                                          CASE 
                                                    WHEN payload -> '$.status.startTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() 
                                                    ELSE JSON_UNQUOTE(payload -> '$.status.startTime') 
                                          END,'%Y-%m-%dT%H:%i:%s' ))) ,
                                           max(TIMESTAMPDIFF(second,prs.most_recent_authorized_time, STR_TO_DATE( 
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
                                    order by row_num desc
  )t3,
  (SELECT @rank:=0) counter 
  ) temp2
  
  , 
  (select '95' as percentile, 1 as row_num
union all select  '90' as percentile, 2  as row_num
union all select  '75' as percentile, 3  as row_num
union all select  '50' as percentile, 4  as row_num
) t4
where rank = t4.row_num",
                    },
                    {
                        name: "E2E PR latency 95th, 90th, 75th, 50th Pct in seconds for last 7 days",
                        sql: " select latency, percentile
 from (
 select *,
 		 @rank :=@rank+ 1 AS rank

  from(       
 SELECT  * 
         from(
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
                                          max(TIMESTAMPDIFF(second,prs.most_recent_authorized_time, STR_TO_DATE( 
                                          CASE 
                                                    WHEN payload -> '$.status.startTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() 
                                                    ELSE JSON_UNQUOTE(payload -> '$.status.startTime') 
                                          END,'%Y-%m-%dT%H:%i:%s' ))) ,
                                           max(TIMESTAMPDIFF(second,prs.most_recent_authorized_time, STR_TO_DATE( 
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
                                    order by row_num desc
  )t3,
  (SELECT @rank:=0) counter 
  ) temp2
  
  , 
  (select '95' as percentile, 1 as row_num
union all select  '90' as percentile, 2  as row_num
union all select  '75' as percentile, 3  as row_num
union all select  '50' as percentile, 4  as row_num
) t4
where rank = t4.row_num",
                    },
                    {
                        name:"PR latency(sam-internal) in seconds",
                        sql: "Select
     PullRequests.pr_num,
     Timestampdiff(second, merged_time,
                           t.manifest_zip_time) AS tnrplatency,
     Timestampdiff(second, PullRequests.`most_recent_authorized_time`, PullRequests.`most_recent_evaluate_pr_completion_time`) evalPrLatency,
     most_recent_authorized_time

FROM PullRequests
LEFT JOIN PullRequestToTeamOrUser on PullRequests.pr_num = PullRequestToTeamOrUser.pr_num
LEFT  JOIN TNRPManifestData t
                       ON              PullRequests.git_hash = t.git_hash
where PullRequests.merged_time > Now() - INTERVAL 1 DAY and PullRequestToTeamOrUser.pr_num is null
 ORDER BY merged_time DESC",

                    },

            ],
    }
