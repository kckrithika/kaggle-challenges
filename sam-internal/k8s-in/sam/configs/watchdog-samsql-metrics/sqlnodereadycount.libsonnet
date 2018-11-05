{
     watchdogFrequency: "15m",
     name: "SqlNodeReadyCount",
     sql: "select 'GLOBAL' as Kingdom, 'NONE' as SuperPod, 'global' as Estate, 'sql.nodeCountByStatus' as Metric, CONCAT('Ready=',Ready) as Tags, Count as Value
from (
  select Ready, Count(*) as Count
  from nodeDetailView
  group by Ready
) as ss
union all
select UPPER(kingdom) as Kingdom, 'NONE' as SuperPod, ControlEstate as Estate, 'sql.sql.nodeCountByStatusPerKingdom' as Metric, CONCAT('Ready=',Ready) as Tags, Count as Value
from (
  select kingdom, ControlEstate, Ready, Count(*) as Count
  from nodeDetailView
  group by kingdom, ControlEstate, Ready
) as ss2",
   }

