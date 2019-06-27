{
    watchdogFrequency: "5m",
    name: "PodAvailabilityByPool",
    sql: "select 'GLOBAL' as MinionPool, 'GLOBAL' as Kingdom, 'sql.available.podStatus' as Metric, Running as Value, CONCAT('Ready=',Phase,',Running=',Running,',Total=',total) as Tags
          from (
            select Phase, Count(CASE WHEN Phase = 'True' THEN 1 ELSE 0 END) as Running, Count(*) as total
            from podDetailView
            group by Phase
          ) as ss1
          union all
          select UPPER(MinionPool) as MinionPool, UPPER(kingdom) as kingdom, 'sql.available.podStatusPerMinionPool' as Metric, Running as Value, CONCAT('Ready=',Phase,',Running=',Running,',Total=',total) as Tags
          from (
            select kingdom, Phase, Count(CASE WHEN Phase = 'True' THEN 1 ELSE 0 END) as Running, Count(*) as total,
            	json_unquote(json_extract(`Payload`, '$.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]')) as MinionPool
            from podDetailView
            group by MinionPool, kingdom, Phase
          ) as ss2",
}