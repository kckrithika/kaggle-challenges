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
    }

