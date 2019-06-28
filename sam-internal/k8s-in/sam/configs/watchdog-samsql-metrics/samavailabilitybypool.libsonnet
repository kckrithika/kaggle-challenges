{
    watchdogFrequency: "5m",
    name: "SAMAvailabilityByPool",
    sql: "select 'NONE' as SuperPod, 'global' as Estate, 'GLOBAL' as Kingdom, 'sql.PoolKingdomCount' as Metric, COUNT(*) as Value
          from (
          	select Kingdom,
          		json_unquote(json_extract(`Payload`, '$.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]')) as MinionPool
          	from podDetailView
          	group by MinionPool, Kingdom
          	) ss1
          INNER JOIN
          (
          	select MinionPool, kingdom, Count(*) as total
              from nodeDetailView
              group by MinionPool, kingdom
          ) ss2
          ON ss1.MinionPool = ss2.MinionPool AND ss1.Kingdom = ss2.Kingdom
          union all
          select 'NONE' as SuperPod, 'global' as Estate, 'GLOBAL' as Kingdom, 'sql.available.PoolKingdomCount' as Metric, COUNT(*) as Value
          FROM
          (select kingdom,
            	SUM(CASE WHEN Phase = 'Running' THEN 1 ELSE 0 END) as Running,
            	json_unquote(json_extract(`Payload`, '$.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]')) as MinionPool
            from podDetailView
            group by MinionPool, kingdom
            having Running>0
          ) ss3
          INNER JOIN
          (select kingdom,
                	SUM(CASE WHEN Ready = 'True' THEN 1 ELSE 0 END) as Running,
                	MinionPool
                from nodeDetailView
                group by MinionPool, kingdom
                having Running>0
          ) ss4
          ON ss3.MinionPool = ss4.MinionPool AND ss3.kingdom = ss4.kingdom",
}