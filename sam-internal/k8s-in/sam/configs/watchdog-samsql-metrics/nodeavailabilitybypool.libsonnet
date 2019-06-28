{
    watchdogFrequency: "5m",
    name: "NodeAvailabilityByPool",
    sql: "select 'GLOBAL' as MinionPool, 'GLOBAL' as Kingdom, 'GLOBAL' as Kingdom, 'global' as Estate, 'sql.available.poolkingdomCount' as Metric, count(*) as Value, 'GLOBAL' as Tags
          from (
          	select MinionPool, kingdom, Ready from nodeDetailView group by MinionPool, kingdom, Ready
          ) as ss1
          union all
          select UPPER(MinionPool) as MinionPool, UPPER(kingdom) as kingdom, 'GLOBAL' as Kingdom, 'global' as Estate, 'sql.available.nodeStatusPerMinionPool' as Metric, (CASE WHEN Running>0 THEN 1 ELSE 0 END) as Value, CONCAT('Ready=',Ready,',Running=',Running,',Total=',total) as Tags
          from (
            select MinionPool, kingdom, Ready, Count(CASE WHEN Ready = 'True' THEN 1 ELSE 0 END) as Running, Count(*) as total
            from nodeDetailView
            group by MinionPool, kingdom, Ready
          ) as ss2",
}