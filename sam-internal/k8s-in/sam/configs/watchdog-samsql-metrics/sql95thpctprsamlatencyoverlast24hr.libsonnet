{
      watchdogFrequency: "15m",
      name: "Sql95thPctPRSamLatencyOverLast24Hr",
      sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate,
'sql.95thPctPRSamLatencyOverLast24Hr' as Metric, IFNULL(samlatencymin,0) as Value, '' as Tags FROM   (  
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
    }

