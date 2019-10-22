{
      sqlkubeapi(action, condition) :: {
          name: "KubeApiNode",
          instructions: "The following minion pools have kubeApi nodes down requiring attention during business hours. Debug Instructions: https://git.soma.salesforce.com/sam/sam/wiki/Repair-Failed-SAM-Host",
          alertThreshold: "20m",
          alertFrequency: "336h",
          watchdogFrequency: "5m",
          alertProfile: "sam",
          alertAction: action,
          instance: "NewNotReadyNodes",
          sql: "SELECT
                      minionpool,
                        TotalApiCount,
                        NotReadyApiCount,
                        NewNotReadyNodes,
                        dist
                      FROM
                      (
                        SELECT
                            minionpool,
                            TotalApiCount,
                            (TotalApiCount - ReadyApiCount) as NotReadyApiCount,
                            (ReadyApiCount - floor(TotalApiCount/2 +1)) as dist,
                            NewNotReadyNodes
                        FROM
                        (
                          SELECT
                            COUNT(*) as TotalApiCount,
                            SUM(CASE WHEN READY = 'True' THEN 1 ELSE 0 END) as ReadyApiCount,
                            minionpool,
                            GROUP_CONCAT(CASE WHEN READY != 'True' THEN name ELSE NULL END) as NewNotReadyNodes
                          FROM
                            nodeDetailView nd
                          WHERE
                            Name like '%kubeapi%'
                            AND minionpool NOT LIKE '%ceph%'
                            AND minionpool NOT LIKE '%slb%'
                            AND minionpool NOT LIKE '%storage%'
                            AND (now() > STR_TO_DATE('2019-07-10', '%Y-%m-%d') OR Name != 'shared0-samkubeapi3-1-par.ops.sfdc.net')
                            AND(now() > STR_TO_DATE('2019-07-10', '%Y-%m-%d') OR Name != 'shared0-samkubeapi2-1-hnd.ops.sfdc.net')
                            AND(now() > STR_TO_DATE('2019-07-10', '%Y-%m-%d') OR Name != 'shared0-samkubeapi2-1-dfw.ops.sfdc.net')
                            AND(now() > STR_TO_DATE('2019-07-10', '%Y-%m-%d') OR Name != 'shared0-samkubeapi1-1-lo2.ops.sfdc.net')
                            AND(now() > STR_TO_DATE('2019-07-10', '%Y-%m-%d') OR Name != 'shared0-samkubeapi3-2-ph2.ops.sfdc.net')
                            AND(now() > STR_TO_DATE('2019-07-10', '%Y-%m-%d') OR Name != 'shared0-samkubeapi2-1-yhu.ops.sfdc.net')
                            AND(now() > STR_TO_DATE('2019-07-10', '%Y-%m-%d') OR Name != 'shared0-samtwokubeapi1-1-prd.eng.sfdc.net')
                            AND(now() > STR_TO_DATE('2019-07-10', '%Y-%m-%d') OR Name != 'shared0-samtestkubeapi3-1-prd.eng.sfdc.net')
                          GROUP BY minionpool
                        ) ss
                        ) ss2
                where NotReadyApiCount>0 and " + condition,
      }
}