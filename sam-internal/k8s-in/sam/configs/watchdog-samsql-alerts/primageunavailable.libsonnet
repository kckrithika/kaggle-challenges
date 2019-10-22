{
      name: "PRImageUnavailable",
      instructions: "Following PRs have at least one image that's not available after 20 minutes of starting deployment",
      alertThreshold: "0m",
      alertFrequency: "336h",
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
    }

