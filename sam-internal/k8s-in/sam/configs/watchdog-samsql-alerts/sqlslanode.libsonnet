{
        name: "SqlSlaNode",
        instructions: "The following minion pools have multiple nodes down in Production requiring immediate attention according to our SLA. Debug Instructions: https://git.soma.salesforce.com/sam/sam/wiki/Repair-Failed-SAM-Host",
        alertThreshold: "20m",
        alertFrequency: "24h",
        watchdogFrequency: "5m",
        alertProfile: "sam",
        alertAction: "pagerduty",
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
                        nodeDetailView nd
                  WHERE
                        KINGDOM != 'PRD' AND KINGDOM != 'UNK'
                        AND minionpool NOT LIKE '%ceph%'
                        AND minionpool NOT LIKE '%slb%'
                        AND minionpool NOT LIKE '%storage%'
                  GROUP BY minionpool
              ) ss
              ) ss2
              WHERE "
              # cdebains is responsible for changing this back
              + "(TotalCount < 10 AND NotReadyCount >=2 AND minionpool like 'par-sam' AND NotReadyPerc >=0.5) 
              OR (TotalCount < 10 AND NotReadyCount >=2 AND minionpool not like 'par-sam')

              OR (TotalCount >= 10 AND NotReadyPerc >=0.2)",
        }

