{
      name: "Minion-Pool-Utilization-Per-Role",
      sql: "select
  HostRole,
  SUM(NodeCount) as AllNodes,
  SUM(NodeReady) as ReadyNodes,
  SUM(HostWithNoSamApp) as IdleNodesWithNoSamApps,
  SUM(SamAppPods) as TotalSamAppPods,
  SUM(SamAppPods)/SUM(NodeCount) as PodToNodeRatio
from
(
  select
    1 as NodeCount,
    (CASE WHEN not Ready is null and Ready = 'True' then 1 else 0 end) as NodeReady,
    Kingdom,
    SUBSTRING(SUBSTRING_INDEX(SUBSTRING_INDEX(Name, '-', 2),'-',-1), 1, CHAR_LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(Name, '-', 2),'-',-1))-1) as HostRole,
    ss0.SamAppPods,
    (CASE WHEN ss0.SamAppPods is null or ss0.SamAppPods = 0 then 1 else 0 end) as HostWithNoSamApp
  from nodeDetailView
  left join
  (
    select CAST(NodeName as BINARY) as NodeName, Count(*) as SamAppPods
    from podDetailView
    where IsSamApp=1 and not NodeName is Null and Phase = 'Running'
    group by NodeName
  ) as ss0
  on nodeDetailView.Name = ss0.NodeName
) as ss
group by HostRole
order by IdleNodesWithNoSamApps desc",
    }
