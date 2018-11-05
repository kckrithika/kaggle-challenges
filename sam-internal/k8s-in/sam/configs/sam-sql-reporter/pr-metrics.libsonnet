{
            name: "PR metrics",
            multisql: [
                {
                    name: "First Approval link post latency",
                    sql: "SELECT
          *
        FROM (SELECT 
            pr_num,
            TIMESTAMPDIFF(SECOND, created_time, CASE WHEN first_approval_link_posted_time IS NULL THEN now() ELSE first_approval_link_posted_time END) latencyInSeconds,
            first_approval_link_posted_time,
            created_time
        FROM PullRequests 
        WHERE created_time IS NOT NULL AND created_time > NOW() - Interval 10 day AND state ='open') approvalLinkInSec
        ORDER BY pr_num desc
        LIMIT 5",
                },
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
                        name: "Sam latency",
                        sql: "SELECT pr_num, 
       totallatencymin - (imagelatencymin + tnrplatency) samlatencymin,
       Imagelatencymin artifactoryLatency,
       tnrplatency,
       totallatencymin e2eLatency
       
FROM   ( 
                       SELECT          pr_num, 
                                       imagelatencymin, 
                                       totallatencymin, 
                                       Timestampdiff(minute, merged_time, 
                                       CASE 
                                                       WHEN t.manifest_zip_time IS NULL THEN Now()
                                                       ELSE t.manifest_zip_time 
                                       END) AS tnrplatency 
                       FROM            ( 
                                                 SELECT    prs.pr_num, 
                                                           prs.git_hash, 
                                                           prs.merged_time, 
                                                           Max(Timestampdiff(minute, Str_to_date(Json_unquote(payload -> '$.status.startTime'),'%Y-%m-%dT%H:%i:%s'), Str_to_date( 
                                                           CASE 
                                                                     WHEN payload -> '$.status.maxImageEndTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() 
                                                                     ELSE Json_unquote(payload -> '$.status.maxImageEndTime') 
                                                           END,'%Y-%m-%dT%H:%i:%s'))) imagelatencymin, 
                                                           Max(Timestampdiff(minute, prs.most_recent_authorized_time, Str_to_date(
                                                           CASE 
                                                                     WHEN payload -> '$.status.endTime' = '0001-01-01T00:00:00Z' THEN CURRENT_TIMESTAMP() 
                                                                     ELSE Json_unquote(payload -> '$.status.endTime') 
                                                           END, '%Y-%m-%dT%H:%i:%s'))) totallatencymin 
                                                 FROM      PullRequests prs 
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
                       LIMIT 10",
                    },
            ],
    }