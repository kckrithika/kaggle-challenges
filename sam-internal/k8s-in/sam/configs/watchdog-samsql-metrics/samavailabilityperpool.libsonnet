{
    watchdogFrequency: "5m",
    name: "SAMAvailabilityPerPool",
    sql: "select 'NONE' as SuperPod, 'global' as Estate, UPPER(ss1.kingdom) as Kingdom, 'sql.PoolKingdomCountPerPool' as Metric, (CASE WHEN PodRunning>0 & NodeRunning>0 THEN 1 ELSE 0 END) as Value, CONCAT('MinionPool=', ss1.MinionPool) as Tags
                    FROM
                    (select kingdom,
                      	SUM(CASE WHEN Phase = 'Running' THEN 1 ELSE 0 END) as PodRunning,
                      	json_unquote(json_extract(`Payload`, '$.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]')) as MinionPool
                      from podDetailView
                      group by MinionPool, kingdom
                    ) ss1
                    INNER JOIN
                    (select kingdom,
                          	SUM(CASE WHEN Ready = 'True' THEN 1 ELSE 0 END) as NodeRunning,
                          	MinionPool
                          from nodeDetailView
                          group by MinionPool, kingdom
                    ) ss2
                    ON ss1.MinionPool = ss2.MinionPool AND ss1.kingdom = ss2.kingdom",
}