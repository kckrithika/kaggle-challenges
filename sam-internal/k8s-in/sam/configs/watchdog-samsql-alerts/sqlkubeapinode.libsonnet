{
      sqlkubeapi(action, condition) :: {
          name: "SqlKubeApiNode",
          instructions: "The following minion pools have kubeApi nodes down requiring attention during business hours. Debug Instructions: https://git.soma.salesforce.com/sam/sam/wiki/Repair-Failed-SAM-Host",
          alertThreshold: "20m",
          alertFrequency: "24h",
          watchdogFrequency: "5m",
          alertProfile: "sam",
          alertAction: action,
          sql: "SELECT
                      minionpool,
                        TotalApiCount,
                        NotReadyApiCount
                      FROM
                      (
                        SELECT
                            minionpool,
                            TotalApiCount,
                            (TotalApiCount - ReadyApiCount) as NotReadyApiCount,
                            (ReadyApiCount - floor(TotalApiCount/2 +1)) as dist
                        FROM
                        (
                          SELECT
                            COUNT(*) as TotalApiCount,
                            SUM(CASE WHEN READY = 'True' THEN 1 ELSE 0 END) as ReadyApiCount,
                            minionpool
                          FROM
                            nodeDetailView nd
                          WHERE
                            Name like '%kubeapi%'
                            AND minionpool NOT LIKE '%ceph%'
                            AND minionpool NOT LIKE '%slb%'
                            AND minionpool NOT LIKE '%storage%'
                            AND (now() > STR_TO_DATE('2019-01-10', '%Y-%m-%d') OR Name != 'shared0-samkubeapi3-1-par.ops.sfdc.net')
                                AND (now() > STR_TO_DATE('2019-01-10', '%Y-%m-%d') OR Name != 'shared0-samkubeapi1-1-phx.ops.sfdc.net')
                                AND (now() > STR_TO_DATE('2019-03-21', '%Y-%m-%d') OR Name != 'shared0-samkubeapi1-1-yhu.ops.sfdc.net')
                          GROUP BY minionpool
                        ) ss
                        ) ss2
                where NotReadyApiCount>0 and " + condition,
      }
}