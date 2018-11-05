{
      name: "Pods-Pending-On-Nodes-Without-Free-IPs",
      sql: "select
  ControlEstate,
  Namespace,
  Name as PodName,
  podDetailView.NodeName,
  Phase,
  Message,
  PodUrl,
  NodeUrl
from podDetailView
inner join 
(
  select
    NodeName
  from  
  (
    select
      NodeName,
      (CASE WHEN COUNT(distinct PodIP) > 28 then 1 else 0 END) as Full
    from
    (
      select
        NodeName,
        (CASE WHEN HostIP = PodIP then NULL else PodIP END) as PodIP
      from
      (
        select 
          NodeName,
          Payload->>'$.status.hostIP' as HostIP,
          Payload->>'$.status.podIP' as PodIP,
          Phase
        from
          podDetailView
      ) as ss
    ) as ss2
    group by NodeName
  ) as ss3
  where Full = 1
) as ss4
on podDetailView.NodeName = ss4.NodeName
where Phase <> 'Running' and IsSamApp = 1
order by ControlEstate, Namespace, PodName",
    }
