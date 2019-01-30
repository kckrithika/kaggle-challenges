{
      watchdogFrequency: "15m",
      name: "Sql95thPctPRSamLatencyOverLast24Hr",
      sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate,
'sql.95thPctPRSamLatencyOverLast24Hr' as Metric, IFNULL(samlatencysec,0) as Value, '' as Tags FROM   (   
              SELECT sam.*,
                     @row_num := @row_num + 1 AS row_num
              FROM   (   
SELECT pr_num, 
       totallatencysec - (imagelatencysec + tnrplatency + evalPrLatency) samlatencysec
FROM   (   
                       SELECT          pr_num, 
                                       imagelatencysec, 
                                       GREATEST(totallatencysec1, totallatencysec2) totallatencysec, 
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
                                                                     WHEN payload -> '$.status.startTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP()        
                                                                     ELSE Json_unquote(payload -> '$.status.startTime')
                                                           END, '%Y-%m-%dT%H:%i:%s'))) totallatencysec1,
                                                           Max(Timestampdiff(second, prs.most_recent_authorized_time, Str_to_date(
                                                           CASE
                                                                     WHEN payload -> '$.status.maxImageEndTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP()        
                                                                     ELSE Json_unquote(payload -> '$.status.maxImageEndTime')
                                                           END, '%Y-%m-%dT%H:%i:%s'))) totallatencysec2,
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
                                                 AND       prs.merged_time > Now() - INTERVAL 1 DAY 
                                                 GROUP BY  prs.pr_num) sam 
                       LEFT OUTER JOIN TNRPManifestData t
                       ON              sam.git_hash = t.git_hash )samNull
                       WHERE totallatencysec IS NOT NULL)sam,
                                       ( SELECT @row_num := 0) counter ORDER BY samlatencysec ) temp
              WHERE  temp.row_num = Round (.95 * @row_num)",
    }

