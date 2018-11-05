{
      name: "Prd-Sandbox-IPs-Used-By-Node",
      sql: "select
  ss3.*,
  (CASE WHEN Ready = 'True' then '' else Ready END) as Ready,
  (CASE WHEN Unschedulable IS NULL then '' else 'True' END) as Unschedulable
from
(
  select
    NodeName,
    SUM(HostIpCount) as NumPodsOnHostIp,
    SUM(PodIpCount) as NumPodsOnPodIps,
    SUM(RunningCount) as NumPodsRunning,
    SUM(PendingCount) as NumPodPending,
    COUNT(distinct PodIP) as UsedPodIps,
    (CASE WHEN COUNT(distinct PodIP) > 28 then 'OUT_OF_IPs' else '' END) as Status
  from
  (
    select
      NodeName,
      (CASE WHEN HostIP = PodIP then HostIP else NULL END) as HostIp,
      (CASE WHEN HostIP = PodIP then 1 else 0 END) as HostIpCount,
      (CASE WHEN HostIP = PodIP then NULL else PodIP END) as PodIP,
      (CASE WHEN HostIP = PodIP then 0 else 1 END) as PodIpCount,
      (CASE WHEN Phase = 'Running' then 1 else 0 END) as RunningCount,
      (CASE WHEN Phase = 'Pending' then 1 else 0 END) as PendingCount
    from
    (
      select 
        NodeName,
        Payload->>'$.status.hostIP' as HostIP,
        Payload->>'$.status.podIP' as PodIP,
        Phase
      from
        podDetailView
      where
        ControlEstate = 'prd-sam' and Namespace != 'user-cbatra'
    ) as ss
  ) as ss2
  where (NodeName like '%samcompute%' or NodeName like '%kubeapi%')
  group by NodeName
) as ss3
inner join nodeDetailView
on BINARY ss3.NodeName = BINARY nodeDetailView.Name
order by UsedPodIps desc, NumPodPending desc",
    }
