# To run this locally before merge, follow instructions here: https://git.soma.salesforce.com/sam/sam/tree/master/pkg/sam-sql-reporter
{
  queries: [
    {
      name: "Kube-Resource-Kafka-Pipeline-Latencies-ByControlEstate",
      sql: "SELECT min(diff_seconds), avg(diff_seconds), max(diff_seconds), ControlEstate 
FROM ( SELECT (ConsumeTime - ProduceTime) / 1000000000 AS diff_seconds, ControlEstate FROM k8s_resource ) AS ss
GROUP BY ControlEstate",
    },

#===================

    {
      name: "Kube-Resource-Kafka-Pipeline-Latencies-ByHour",
      sql: "SELECT Count(*) as Count, avg(diff_seconds), std(diff_seconds), min(diff_seconds), max(diff_seconds), FROM_UNIXTIME(ProduceTime / 1000000000, \"%y-%m-%d %k\") as DayHour
FROM ( SELECT (ConsumeTime - ProduceTime) / 1000000000 AS diff_seconds, ProduceTime FROM k8s_resource ) AS ss
GROUP BY DayHour;",
    },

#===================

    {
      name: "Host-Os-Versions-Aggregate",
      sql: "SELECT kernelVersion, COUNT(*) FROM nodeDetailView GROUP BY kernelVersion ORDER BY kernelVersion DESC",
    },

#===================

    {
      name: "Host-Os-Versions",
      sql: "SELECT Name, kernelVersion FROM nodeDetailView ORDER BY kernelVersion DESC",
    },

#===================

    {

      name: "Hosts-All",
      sql: "SELECT * FROM nodeDetailView",
    },

#===================

    {
      name: "Hosts-Not-Ready-Sam",
     sql: "SELECT * FROM nodeDetailView WHERE Ready != 'True' AND NOT Name like '%minionceph%'",
    },

#===================

    {
      name: "Hosts-Not-Ready-Ceph",
     sql: "SELECT * FROM nodeDetailView WHERE Ready != 'True' AND Name like '%minionceph%'",
    },

#===================

    {
      name: "Hosts-Docker-Version",
      sql: "SELECT ControlEstate, Name, containerRuntimeVersion FROM nodeDetailView ORDER BY containerRuntimeVersion",
    },

#===================

    {
      name: "Hosts-Kube-Version",
      sql: "SELECT Name, kubeletVersion, Ready FROM nodeDetailView ORDER BY kubeletVersion",
    },

#===================

    {
      name: "Hosts-Kube-Version-Aggregate",
      sql: "SELECT Kingdom, kubeletVersion, COUNT(*) FROM nodeDetailView GROUP BY Kingdom, kubeletVersion ORDER BY kubeletVersion",
    },

#===================

    {
      name: "Resource-Types-By-Kingdom",
      sql: "SELECT ControlEstate, ApiKind, Count(*) FROM ( SELECT ControlEstate, ApiKind, IsTombstone FROM k8s_resource where IsTombstone <> 1) AS ss GROUP BY ControlEstate, ApiKind ORDER BY ControlEstate",
    },

#===================

    {
      name: "Failed-Watchdog-CRDs",
      sql: "SELECT ControlEstate, Name, Payload, ProduceTime, ConsumeTime, IsTombstone FROM k8s_resource WHERE ApiKind='Watchdog' AND JSON_EXTRACT(Payload, '$.status.report.Success') = false",
    },

#===================

    {
      name: "Successful-Watchdog-CRDs",
      sql: "SELECT ControlEstate, Name, Payload, ProduceTime, ConsumeTime, IsTombstone FROM k8s_resource WHERE ApiKind='Watchdog' AND JSON_EXTRACT(Payload, '$.status.report.Success') = true",
    },

#===================

    {
      name: "Number of Failed WatchDogs across Estates",
      sql: "
      SELECT
        ControlEstate,
        JSON_UNQUOTE(JSON_EXTRACT(Payload, '$.status.report.CheckerName')) AS 'CheckerName',
        JSON_EXTRACT(Payload, '$.status.report.Success') AS 'Success',
        COUNT(*) AS 'COUNT'
      FROM k8s_resource
      WHERE ApiKind='Watchdog' AND JSON_EXTRACT(Payload, '$.status.report.Success')=false
      GROUP BY ControlEstate, JSON_UNQUOTE(JSON_EXTRACT(Payload, '$.status.report.CheckerName')), JSON_EXTRACT(Payload, '$.status.report.Success')
      ORDER BY COUNT(*) DESC
      ",
    },

#===================

    {
      name: "Number of Failed WatchDogs across Kingdoms",
      sql: "
      SELECT
        JSON_UNQUOTE(JSON_EXTRACT(Payload, '$.status.report.Kingdom')) as 'Kingdom',
        JSON_UNQUOTE(JSON_EXTRACT(Payload, '$.status.report.CheckerName')) AS 'Checker',
        JSON_EXTRACT(Payload, '$.status.report.Success') AS 'Success',
        COUNT(*) AS 'COUNT'
      FROM k8s_resource
      WHERE ApiKind='Watchdog' AND JSON_EXTRACT(Payload, '$.status.report.Success')=false

      GROUP BY JSON_UNQUOTE(JSON_EXTRACT(Payload, '$.status.report.Kingdom')), JSON_UNQUOTE(JSON_EXTRACT(Payload, '$.status.report.CheckerName')), JSON_EXTRACT(Payload, '$.status.report.Success')
      ORDER BY COUNT(*) DESC
      ",
    },

#===================

    {
      name: "Bad-Customer-Deployments-Production",
      sql: "SELECT * FROM
(
  SELECT
    ControlEstate,
    Namespace, 
    Name,
    JSON_EXTRACT(Payload, '$.metadata.annotations.\"smb.sam.data.sfdc.net/emailTo\"') AS email,
    JSON_EXTRACT(Payload, '$.spec.replicas') AS desiredReplicas,
    JSON_EXTRACT(Payload, '$.status.availableReplicas') AS availableReplicas, 
    JSON_EXTRACT(Payload, '$.status.replicas') AS replicas,
    JSON_EXTRACT(Payload, '$.status.readyReplicas') AS readyReplicas,
    JSON_EXTRACT(Payload, '$.status.updatedReplicas') AS updatedReplicas,
    CONCAT('http://dashboard-',SUBSTR(ControlEstate, 1, 3),'-sam.csc-sam.prd-sam.prd.slb.sfdc.net/#!/deployment/',Namespace,'/',Name,'?namespace=',Namespace) AS Url
  FROM k8s_resource
  WHERE ApiKind = 'Deployment'
) AS ss
WHERE
  ( Namespace != 'sam-watchdog' AND Namespace != 'sam-system' AND Namespace != 'csc-sam') AND
  (availableReplicas != desiredReplicas OR availableReplicas IS NULL) AND
  NOT ControlEstate LIKE 'prd-%' AND
  desiredReplicas != 0",
    },

#===================

    {
      name: "Bad-Pods-By-Host-Production",
      sql: "select * from (
select
        NodeName,
        NodeUrl,
        SUM(PendingCount) AS PendingCount,
        SUM(FailedCount) AS FailedCount,
        SUM(SucceededCount) AS SucceededCount,
        SUM(OtherCount) AS OtherCount,
        SUM(RunningCount) AS RunningCount,
        GROUP_CONCAT(CustomerPodWithIssue SEPARATOR '; ') AS CustomerPodWithIssue,
        GROUP_CONCAT(SystemPodWithIssue SEPARATOR '; ') AS SystemPodWithIssue
from (
        select
                NodeName,
                CASE WHEN Phase = 'Pending' THEN 1 ELSE 0 END AS PendingCount,
                CASE WHEN Phase = 'Failed' THEN 1 ELSE 0 END AS FailedCount,
                CASE WHEN Phase = 'Succeeded' THEN 1 ELSE 0 END AS SucceededCount,
                CASE WHEN Phase != 'Running' AND Phase != 'Pending' AND Phase != 'Failed' AND Phase != 'Succeeded' THEN 1 ELSE 0 END AS OtherCount,
                CASE WHEN Phase = 'Running' THEN 1 ELSE 0 END AS RunningCount,
                CASE WHEN Phase != 'Running' AND (Namespace = 'sam-system' OR Namespace = 'sam-watchdog' OR Namespace = 'csc-sam') THEN Name ELSE NULL END AS SystemPodWithIssue,
                CASE WHEN Phase != 'Running' AND (Namespace != 'sam-system' AND Namespace != 'sam-watchdog' AND Namespace != 'csc-sam') THEN Name ELSE NULL END AS CustomerPodWithIssue,
                NodeUrl
        from
                podDetailView
        where
                Kingdom != 'prd'
                AND NodeName is not NULL
                AND NOT (NodeName like '%samminionceph%')
) as ss
group by NodeName, NodeUrl
) as ss2
where (PendingCount+FailedCount+SucceededCount+OtherCount)>0
order by PendingCount+FailedCount+SucceededCount+OtherCount desc",
    },

#===================

    {
      name: "Bad-Customer-Pods",
      sql: "select
        Kingdom, Namespace, Name AS PodName, Phase, NodeName, PodUrl, NodeUrl
from
        podDetailView
where
        Kingdom != 'prd'
        and not (NodeName like '%samminionceph%')
        and (Namespace != 'sam-system' AND Namespace != 'sam-watchdog' AND Namespace != 'csc-sam')
        and Phase != 'Running'",
    },

#===================

    {
      name: "Image-Pull-Errors",
      sql: "select
  ControlEstate,
  Namespace,
  Payload->>'$.message' as Message,
  Payload->>'$.source.host' as Host,
  Payload->>'$.involvedObject.kind' as InvolvedObjKind,
  Payload->>'$.involvedObject.name' as InvolvedObjName,
  Payload->>'$.involvedObject.namespace' as InvolvedObjNamespace
from
  k8s_resource
where
  ApiKind like 'Event' and
  Payload->>'$.message' like '%ImagePullBackOff%'",
    },

#===================

    {
      name: "Sam-App-Pod-Age-All-Kingdoms",
      sql: "select
  PodAgeDays,
  SUM(CASE WHEN ControlEstate = 'prd-sam' then Count else 0 END) as 'PrdSam',
  SUM(CASE WHEN ControlEstate = 'prd-samdev' then Count else 0 END) as 'PrdSamDev',
  SUM(CASE WHEN ControlEstate = 'prd-samtest' then Count else 0 END) as 'PrdSamTest',
  SUM(CASE WHEN ControlEstate = 'frf-sam' then Count else 0 END) as 'FrfSam',
  SUM(CASE WHEN ControlEstate = 'phx-sam' then Count else 0 END) as 'PhxSam',
  SUM(CASE WHEN ControlEstate = 'par-sam' then Count else 0 END) as 'ParSam',
  SUM(CASE WHEN ControlEstate = 'ord-sam' then Count else 0 END) as 'OrdSam',
  SUM(CASE WHEN ControlEstate = 'iad-sam' then Count else 0 END) as 'IadSam',
  SUM(CASE WHEN ControlEstate = 'hnd-sam' then Count else 0 END) as 'HndSam',
  SUM(CASE WHEN ControlEstate = 'dfw-sam' then Count else 0 END) as 'DfwSam',
  SUM(CASE WHEN ControlEstate = 'ukb-sam' then Count else 0 END) as 'UkbSam',
  SUM(CASE WHEN ControlEstate = 'cdu-sam' then Count else 0 END) as 'CduSam',
  SUM(CASE WHEN ControlEstate = 'syd-sam' then Count else 0 END) as 'SydSam',
  SUM(CASE WHEN ControlEstate = 'yhu-sam' then Count else 0 END) as 'YhuSam',
  SUM(CASE WHEN ControlEstate = 'yul-sam' then Count else 0 END) as 'YulSam',
  SUM(CASE WHEN ControlEstate = 'chx-sam' then Count else 0 END) as 'ChxSam',
  SUM(CASE WHEN ControlEstate = 'wax-sam' then Count else 0 END) as 'WaxSam'
from
(
  select
    ControlEstate,
    PodAgeDays,
    COUNT(*) as Count
  from
  (
    select
      ControlEstate,
      LEAST(FLOOR(PodAgeInMinutes/60.0/24.0),10) as PodAgeDays
    from podDetailView
    where IsSamApp = True and ProduceAgeInMinutes<15
  ) as ss
  where PodAgeDays IS NOT NULL
  group by ControlEstate, PodAgeDays
) as ss2
group by PodAgeDays",
    },

#===================

    {
      name: "Sam-App-Pod-Age-Prd",
      sql: "select
  PodAgeDays,
  SUM(CASE WHEN ControlEstate = 'prd-sam' then Count else 0 END) as 'PrdSam',
  SUM(CASE WHEN ControlEstate = 'prd-samdev' then Count else 0 END) as 'PrdSamDev',
  SUM(CASE WHEN ControlEstate = 'prd-samtest' then Count else 0 END) as 'PrdSamTest'
from
(
  select
    ControlEstate,
    PodAgeDays,
    COUNT(*) as Count
  from
  (
    select
      ControlEstate,
      LEAST(FLOOR(PodAgeInMinutes/60.0/24.0),10) as PodAgeDays
    from podDetailView
    where IsSamApp = True and ProduceAgeInMinutes<15
  ) as ss
  where PodAgeDays IS NOT NULL
  group by ControlEstate, PodAgeDays
) as ss2
group by PodAgeDays",
    },

#===================

    {
      name: "MySql-Pods-With-Old-Produce-Age",
      sql: "select
  NamespacePodPrefix,
  SUM(Count) as Count,
  GROUP_CONCAT(ControlEstate, ' ')
from
(
  select
    NamespacePodPrefix,
    ControlEstate,
    COUNT(*) as Count
  from
  (
    select
      CONCAT(Namespace, ' ', SUBSTRING_INDEX(Name, '-', 1)) as NamespacePodPrefix,
      ControlEstate
    from podDetailView
    where IsSamApp = True and ProduceAgeInMinutes>60.0
  ) as ss
  group by NamespacePodPrefix, ControlEstate
) as ss2
group by NamespacePodPrefix
order by Count desc",
    },

#===================

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
    },

#===================

    {
      name: "Prd-All-IPs-Used-By-Node",
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
        ControlEstate = 'prd-sam'
    ) as ss
  ) as ss2
  group by NodeName
) as ss3
inner join nodeDetailView
on BINARY ss3.NodeName = BINARY nodeDetailView.Name
order by UsedPodIps desc, NumPodPending desc",
    },

#===================

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
    },

#===================

    {
      name: "SamSystem-Overview",
      sql: "select
  controlEstate,
  sum(Running) as Running,
  sum(NotRunning) as NotRunning,
  sum(Running) / (sum(Running)+sum(NotRunning)) as PctHealthy,
  group_concat(FailingSam, '') as FailingSam,
  group_concat(FailingOther, '') as FailingOther
from
(
select
  controlEstate,
  (CASE WHEN Phase <> 'Running' and Name not like '%slb%' and Name not like '%sdn%' then name else null end) as FailingSam,
  (CASE WHEN Phase <> 'Running' and (Name like '%slb%' or Name like '%sdn%') then name else null end) as FailingOther,
  (CASE WHEN Phase = 'Running' then 1 else 0 end) as Running,
  (CASE WHEN Phase <> 'Running' then 1 else 0 end) as NotRunning
from podDetailView
where namespace = 'sam-system'
) as ss
group by controlEstate
order by NotRunning desc",
    },

#===================

    {
      name: "SamSystem-Failed-Pods-Sam",
      sql: "select ControlEstate, Name, NodeName, Phase, Message, PodUrl from podDetailView where namespace = 'sam-system' and Phase <> 'Running' and Name not like '%slb%' and Name not like '%sdn%' order by ControlEstate, Name",
    },

#===================

    {
      name: "SamSystem-Failed-Pods-NonSam",
      sql: "select ControlEstate, Name, NodeName, Phase, Message, PodUrl from podDetailView where namespace = 'sam-system' and Phase <> 'Running' and (Name like '%slb%' or Name like '%sdn%') order by ControlEstate, Name",
    },

#===================

    {
      name: "Minion-Pool-Utilization-Per-Kingdom",
      sql: "select
  HostRole,
  Kingdom,
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
group by HostRole, Kingdom
order by HostRole, Kingdom",
    },

#===================

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
    },

#===================

    {
      name: "FsChecker-Errors-Agg",
      sql: "select
  kernelVersion,
  sum(errorCount) as HostWithFsErrors,
  sum(goodCount) as GoodHosts,
  group_concat(errorHostname,'') as HostWithErrors,
  group_concat(errorMessage,'') as ErrorMessage
from
(
  select *
  from
  (
    select
      Payload->>'$.spec.hostname' as hostName,
      case when Payload->>'$.status.report.ErrorMessage' = 'null' then null else Payload->>'$.spec.hostname' end as errorHostname,
      case when Payload->>'$.status.report.ErrorMessage' = 'null' then null else Payload->>'$.status.report.ErrorMessage' end as errorMessage,
      case when Payload->>'$.status.report.ErrorMessage' = 'null' then 0 else 1 end as errorCount,
      case when Payload->>'$.status.report.ErrorMessage' = 'null' then 1 else 0 end as goodCount
    from
      k8s_resource
    where ApiKind = 'WatchDog' and
    Payload->>'$.spec.checkername' like 'filesystemchecker%'
  ) as fsChecker
  left join
  (
    select 
      Name,
      kernelVersion
    from nodeDetailView
  ) as pod
  on ( binary fsChecker.hostName = pod.Name  )
) as ss
group by kernelVersion ",
    },

#===================

    {
      name: "FsChecker-Errors",
      sql: "select
  hostName, kernelVersion, errorMessage, controlEstate  
from
(
  select
    controlEstate,
    Payload->>'$.spec.hostname' as hostName,
    Payload->>'$.status.report.ErrorMessage' as errorMessage
  from
    k8s_resource
  where ApiKind = 'WatchDog' and
  Payload->>'$.spec.checkername' like 'filesystemchecker%' and
  Payload->>'$.status.report.ErrorMessage' != 'null'
) as fsChecker
left join
(
  select 
    Name,
    kernelVersion
  from nodeDetailView
) as pod
on ( binary fsChecker.hostName = pod.Name )",
    },

#===================
#
#    {
#      name: "",
#      sql: "",
#    },

  ],
}
