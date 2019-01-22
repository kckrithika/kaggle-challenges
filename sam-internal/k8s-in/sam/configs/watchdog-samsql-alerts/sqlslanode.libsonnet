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
                        AND minionpool NOT LIKE '%chatbot%'
                  GROUP BY minionpool
              ) ss
              ) ss2
              WHERE
              ((TotalCount >= 10 AND NotReadyPerc >=0.2)
              OR
              (TotalCount < 10 AND NotReadyCount >=2))
              "
              # add snooze conditions with expiration time
              + "
              AND NOT
              (minionpool like 'par-sam' AND NotReadyPerc < 0.5 AND now() < STR_TO_DATE('2019-02-01', '%Y-%m-%d'))
              AND NOT
              (minionpool like 'phx-sam_mgmt_hub' AND now() < STR_TO_DATE('2019-01-22', '%Y-%m-%d'))
              AND NOT
              (minionpool like 'ph2-sam_gater' AND NotReadyPerc < 0.5 AND now() < STR_TO_DATE('2019-01-30', '%Y-%m-%d'))",
        }

