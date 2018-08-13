# To run this locally before merge, follow instructions here: https://git.soma.salesforce.com/sam/sam/tree/master/pkg/sam-sql-reporter

local bedhealth(type, bed) = {
    name: "Bed Health - " + type + " - " + bed,
    note: "This view gives an overview of everything running on " + bed + ".  When using this for release validation, follow the steps in <a href='https://git.soma.salesforce.com/sam/sam/wiki/Deploy-SAM'>this wiki page</a>",
    multisql: [

      # ===

      {
        name: "HyperSam Tags",
        note: "Currently running tags for hypersam in sam-system",
        sql: "select * from (
      select
        ControlEstate, Image, Tag, count(*) as Count, group_concat(Name) as Resources
      from
      (
        select
          Name,
          ControlEstate,
          substring_index(substring_index(Image, ':', 1), '/', -1) as Image,
          substring_index(Image, ':', -1) as Tag
        from
        (
          select
            Name,
            ControlEstate,
            json_unquote(json_extract(Images, concat('$[',n,']'))) as Image
          from
          (
            select * from
            (
              select '0' n union select '1' n union select '2' n union select '3' n union select '4' n union select '5' n union select '6' n
            ) num
            join
            (
            select Name, ControlEstate, Payload->>'$.spec.template.spec.containers[*].image' as Images
            from k8s_resource
            where
              (ApiKind = 'Deployment' or ApiKind = 'DaemonSet') and
              namespace = 'sam-system' and
              Payload->>'$.metadata.labels.\"\\sam\\.data\\.sfdc\\.net\\/owner\"' = 'sam'
            ) ss
          ) ss2
        having not Image is NULL
        ) ss3
      ) ss4
      Where controlEstate = '" + bed + "' and Image = 'hypersam'
      group by ControlEstate, Image, Tag
      order by ControlEstate, Image
      ) ss5
      order by Count desc",
              },

              # ===

              {
                name: "Unhealthy Pods in Sam-System",
                note: "Problems with our control stack should be investigated.  DaemonSets on down machines are not blocking, but we should try to get the machines back online.",
                sql: "select
        case when (Phase='Pending' and Name like '%watchdog%') then 'YELLOW' else 'RED' end as Status,
        ControlEstate,
        Namespace,
        Name,
        NodeName,
        Phase,
        Message,
       Payload->>'$.status.conditions' as Conditions
      from podDetailView
      where
        namespace = 'sam-system'
        and ControlEstate = '" + bed + "'
        and Phase <> 'Running'
        and Name not like '%slb%'
        and Name not like '%sdn%'",
              },

              # ===

              {
                name: "Watchdog failures",
                note: "For phased releases, items in red should be fixed.",
                sql: "select * from (
        select
        case when GROUP_CONCAT(Error, '') is null then '' when CheckerName in ('puppetChecker', 'kubeResourcesChecker', 'nodeChecker') then 'YELLOW' else 'RED' end as Status,
        CheckerName,
        SUM(SuccessCount) as SuccessCount,
        SUM(FailureCount) as FailureCount,
        SUM(SuccessCount)/(SUM(SuccessCount)+SUM(FailureCount)) as SuccessPct,
        GROUP_CONCAT(Error, '') as Errors,
        CONCAT('https://argus-ui.data.sfdc.net/argus/#/viewmetrics?expression=-14d:sam.watchdog.',Kingdom,'.NONE.',ControlEstate,':',CheckerName,'.status%7Bdevice%3D*%7D:avg') as Argus
      from
      (
      select
        CAST(ControlEstate as CHAR CHARACTER SET utf8) AS ControlEstate,
        CAST(upper(substr(ControlEstate,1,3)) as CHAR CHARACTER SET utf8) AS Kingdom,
        Payload->>'$.status.report.CheckerName' as CheckerName,
        case when Payload->>'$.status.report.Success' = 'true' then 1 else 0 end as SuccessCount,
        case when Payload->>'$.status.report.Success' = 'false' then 1 else 0 end as FailureCount,
        case when Payload->>'$.status.report.ErrorMessage' = 'null' then null else Payload->>'$.status.report.ErrorMessage' end as Error
      from k8s_resource
      where ApiKind = 'WatchDog'
      and controlestate = '" + bed + "'
      ) as ss
      where CheckerName not like 'Sql%' and
      CheckerName not like 'MachineCount%'
      group by CheckerName
      ) as ss2
      order by SuccessPct",
      },

              # ===

              {
                name: "SAM Customer App Pod Age",
                note: "When doign a phased release, apps with low age need to be investigated to make sure we did not change PodSpecTemplate by accident.  Steps to investigate pod restarts can be found <a href='https://git.soma.salesforce.com/sam/sam/wiki/Deploy-SAM'>here</a>",
                sql: "select
        ControlEstate,
        PodAgeDays,
        PodsWithThisAge
      from
      (
        select
          ControlEstate,
          PodAgeDays,
          SUM(Count) as PodsWithThisAge
        from
        (
          select
            ControlEstate,
            LEAST(FLOOR(PodAgeInMinutes/60.0/24.0),10) as PodAgeDays,
            1 as Count
          from podDetailView
          where IsSamApp = True and ProduceAgeInMinutes<60
          and ControlEstate = '" + bed + "'
          union all
          select '" + bed + "' as ControlEstate, 0 as PodAgeDays, 0 as Count
          union all
          select '" + bed + "' as ControlEstate, 1 as PodAgeDays, 0 as Count
          union all
          select '" + bed + "' as ControlEstate, 2 as PodAgeDays, 0 as Count
          union all
          select '" + bed + "' as ControlEstate, 3 as PodAgeDays, 0 as Count
          union all
          select '" + bed + "' as ControlEstate, 4 as PodAgeDays, 0 as Count
          union all
          select '" + bed + "' as ControlEstate, 5 as PodAgeDays, 0 as Count
          union all
          select '" + bed + "' as ControlEstate, 6 as PodAgeDays, 0 as Count
          union all
          select '" + bed + "' as ControlEstate, 7 as PodAgeDays, 0 as Count
          union all
          select '" + bed + "' as ControlEstate, 8 as PodAgeDays, 0 as Count
          union all
          select '" + bed + "' as ControlEstate, 9 as PodAgeDays, 0 as Count
          union all
          select '" + bed + "' as ControlEstate, 10 as PodAgeDays, 0 as Count
        ) as ss
        where PodAgeDays IS NOT NULL
        group by ControlEstate, PodAgeDays
      ) as ss2
      group by ControlEstate, PodAgeDays",
              },

              # ===

              {
                name: "List of customer pods ordered by PodAge (top 30)",
                sql: "select
            case when (LEAST(FLOOR(PodAgeInMinutes/60.0/24.0),10)<2) then 'YELLOW' else '' end as Status,
            Name,
            Namespace,
            ControlEstate,
            LEAST(FLOOR(PodAgeInMinutes/60.0/24.0),10) as PodAgeDays,
            Phase
          from podDetailView
          where IsSamApp = True and ProduceAgeInMinutes<60 and Phase = 'Running'
          and ControlEstate = '" + bed + "'
          order by PodAgeDays
          limit 30",
              },

             # ===

             {
               name: "Unhealthy customer pods",
               sql: "select 
  Name,
  Namespace,
  ControlEstate,
  Phase,
  Message,
  case when Phase != 'Running' then Payload->>'$.status.conditions[*].message' end as Conditions,
  case when Phase != 'Running' then Payload->>'$.status.containerStatuses[*].state' end as containerStatuses
from podDetailView
where IsSamApp = True and ProduceAgeInMinutes<60
and ControlEstate = '" + bed + "' and Phase != 'Running'
",
            },

    ],
  };


{
  queries: [


#===================

    bedhealth("R&D", "prd-samdev"),
    bedhealth("R&D", "prd-samtest"),
    bedhealth("R&D", "prd-sam"),
    bedhealth("R&D", "prd-samtwo"),
    bedhealth("R&D", "xrd-sam"),

    bedhealth("PROD", "cdg-sam"),
    bedhealth("PROD", "cdu-sam"),
    bedhealth("PROD", "chx-sam"),
    bedhealth("PROD", "dfw-sam"),
    bedhealth("PROD", "frf-sam"),
    bedhealth("PROD", "hnd-sam"),
    bedhealth("PROD", "ia2-sam"),
    bedhealth("PROD", "iad-sam"),
    bedhealth("PROD", "ord-sam"),
    bedhealth("PROD", "par-sam"),
    bedhealth("PROD", "ph2-sam"),
    bedhealth("PROD", "phx-sam"),
    bedhealth("PROD", "syd-sam"),
    bedhealth("PROD", "ukb-sam"),
    bedhealth("PROD", "wax-sam"),
    bedhealth("PROD", "yhu-sam"),
    bedhealth("PROD", "yul-sam"),


#===================

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
      name: "Watchdog Aggregate Status by Checker",
      sql: "select
  CheckerName,
  SUM(SuccessCount) as SuccessCount,
  SUM(FailureCount) as FailureCount,
  SUM(SuccessCount)/(SUM(SuccessCount)+SUM(FailureCount)) as SuccessPct
from
(
select
  Payload->>'$.status.report.CheckerName' as CheckerName,
  case when Payload->>'$.status.report.Success' = 'true' then 1 else 0 end as SuccessCount,
    case when Payload->>'$.status.report.Success' = 'false' then 1 else 0 end as FailureCount
from k8s_resource
where ApiKind = 'WatchDog'
) as ss
where CheckerName not like 'Sql%' and 
CheckerName not like 'MachineCount%'
group by CheckerName
order by SuccessPct desc
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
    where IsSamApp = True and ProduceAgeInMinutes<60
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
    where IsSamApp = True and ProduceAgeInMinutes<60
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

    {
      name: "HyperSam Docker Tags in PRD",
      note: "Currently running hypersam tag for sam-system deployments and daemon sets owned by sam",
      multisql: [
        {
          name: "Hypersam in prd-samtest (Phase 0)",
          sql: "select
  ControlEstate, Image, Tag, count(*) as Count, group_concat(Name) as Resources
from
(
  select
    Name,
    ControlEstate,
    substring_index(substring_index(Image, ':', 1), '/', -1) as Image,
    substring_index(Image, ':', -1) as Tag
  from
  (
    select
      Name,
      ControlEstate,
      json_unquote(json_extract(Images, concat('$[',n,']'))) as Image
    from
    (
      select * from
      (
        select '0' n union select '1' n union select '2' n union select '3' n union select '4' n union select '5' n union select '6' n
      ) num
      join
      (
      select Name, ControlEstate, Payload->>'$.spec.template.spec.containers[*].image' as Images
      from k8s_resource
      where 
        (ApiKind = 'Deployment' or ApiKind = 'DaemonSet') and 
        namespace = 'sam-system' and
        Payload->>'$.metadata.labels.\"\\sam\\.data\\.sfdc\\.net\\/owner\"' = 'sam'
      ) ss
    ) ss2
  having not Image is NULL
  ) ss3
) ss4
Where controlEstate = 'prd-samtest' and Image = 'hypersam'
group by ControlEstate, Image, Tag
order by ControlEstate, Image",
        },
        {
          name: "Hypersam in prd-samdev (Phase 1)",
          sql: "select
  ControlEstate, Image, Tag, count(*) as Count, group_concat(Name) as Resources
from
(
  select
    Name,
    ControlEstate,
    substring_index(substring_index(Image, ':', 1), '/', -1) as Image,
    substring_index(Image, ':', -1) as Tag
  from
  (
    select
      Name,
      ControlEstate,
      json_unquote(json_extract(Images, concat('$[',n,']'))) as Image
    from
    (
      select * from
      (
        select '0' n union select '1' n union select '2' n union select '3' n union select '4' n union select '5' n union select '6' n
      ) num
      join
      (
      select Name, ControlEstate, Payload->>'$.spec.template.spec.containers[*].image' as Images
      from k8s_resource
      where 
        (ApiKind = 'Deployment' or ApiKind = 'DaemonSet') and 
        namespace = 'sam-system' and
        Payload->>'$.metadata.labels.\"\\sam\\.data\\.sfdc\\.net\\/owner\"' = 'sam'
      ) ss
    ) ss2
  having not Image is NULL
  ) ss3
) ss4
Where controlEstate = 'prd-samdev' and Image = 'hypersam'
group by ControlEstate, Image, Tag
order by ControlEstate, Image",
        },
        {
          name: "Hypersam in prd-sam (Phase 2)",
          sql: "select
  ControlEstate, Image, Tag, count(*) as Count, group_concat(Name) as Resources
from
(
  select
    Name,
    ControlEstate,
    substring_index(substring_index(Image, ':', 1), '/', -1) as Image,
    substring_index(Image, ':', -1) as Tag
  from
  (
    select
      Name,
      ControlEstate,
      json_unquote(json_extract(Images, concat('$[',n,']'))) as Image
    from
    (
      select * from
      (
        select '0' n union select '1' n union select '2' n union select '3' n union select '4' n union select '5' n union select '6' n
      ) num
      join
      (
      select Name, ControlEstate, Payload->>'$.spec.template.spec.containers[*].image' as Images
      from k8s_resource
      where 
        (ApiKind = 'Deployment' or ApiKind = 'DaemonSet') and 
        namespace = 'sam-system' and
        Payload->>'$.metadata.labels.\"\\sam\\.data\\.sfdc\\.net\\/owner\"' = 'sam'
      ) ss
    ) ss2
  having not Image is NULL
  ) ss3
) ss4
Where controlEstate = 'prd-sam' and Image = 'hypersam'
group by ControlEstate, Image, Tag
order by ControlEstate, Image",
        },
      ],
    },

#===================

    {
      name: "MySQL Pods by Produce Age",
      note: "This shows the count of pods by produce age bucket.  Ideally most of our pods should have a produce age less than 15 minutes.  Large number of pods above this indicates an issue.  <a href='https://git.soma.salesforce.com/sam/sam/wiki/Debugging-Visibility-Pipeline'>Debug Instructions</a>",
      sql: "select
  SUM(lt5m),
  SUM(lt10m),
  SUM(lt15m),
  SUM(lt20m),
  SUM(lt25m),
  SUM(lt30m),
  SUM(lt40m),
  SUM(lt50m),
  SUM(lt60m),
  SUM(lt120m),
  SUM(ltMax)
from (
select
  CASE WHEN ProduceAgeInMinutes<5 THEN 1 ELSE 0 END as lt5m,
  CASE WHEN ProduceAgeInMinutes<10 THEN 1 ELSE 0 END as lt10m,
  CASE WHEN ProduceAgeInMinutes<15 THEN 1 ELSE 0 END as lt15m,
  CASE WHEN ProduceAgeInMinutes<20 THEN 1 ELSE 0 END as lt20m,
  CASE WHEN ProduceAgeInMinutes<25 THEN 1 ELSE 0 END as lt25m,
  CASE WHEN ProduceAgeInMinutes<30 THEN 1 ELSE 0 END as lt30m,
  CASE WHEN ProduceAgeInMinutes<40 THEN 1 ELSE 0 END as lt40m,
  CASE WHEN ProduceAgeInMinutes<50 THEN 1 ELSE 0 END as lt50m,
  CASE WHEN ProduceAgeInMinutes<60 THEN 1 ELSE 0 END as lt60m,
  CASE WHEN ProduceAgeInMinutes<120 THEN 1 ELSE 0 END as lt120m,
  1 as ltMax
from
  podDetailView
) as ss",
    },

#===================

    {
      name: "SAM Node Status Aggregate",
      sql: "select * from (
select * from (
select ControlEstate,
SUM(ReadyCount) as Ready,
SUM(NotReadyCount) as NotReady,
SUM(NotReadyCount)+SUM(ReadyCount) as Total,
SUM(ReadyCount)/(SUM(NotReadyCount)+SUM(ReadyCount)) as ReadyPct,
GROUP_CONCAT(NotReadyName) as NotReadyHosts
from
(
select 'TOTAL' as ControlEstate,
NULL as NotReadyName,
case when Ready = 'True' then 1 else 0 end as ReadyCount,
case when Ready = 'True' then 0 else 1 end as NotReadyCount
from nodeDetailView
where 
	(Name not like '%slb%')
	and (Name not like '%ceph%')
	and (Name not like '%sdc%')
	and (Name not like '%flowsnake%')

) as ss
group by ControlEstate
) as ss2

union

select * from (
select ControlEstate,
SUM(ReadyCount) as Ready,
SUM(NotReadyCount) as NotReady,
SUM(NotReadyCount)+SUM(ReadyCount) as Total,
SUM(ReadyCount)/(SUM(NotReadyCount)+SUM(ReadyCount)) as ReadyPct,
GROUP_CONCAT(NotReadyName) as NotReadyHosts
from
(
select ControlEstate,
case when Ready = 'True' then NULL else Name end as NotReadyName,
case when Ready = 'True' then 1 else 0 end as ReadyCount,
case when Ready = 'True' then 0 else 1 end as NotReadyCount
from nodeDetailView
where 
	(Name not like '%slb%')
	and (Name not like '%ceph%')
	and (Name not like '%sdc%')
	and (Name not like '%flowsnake%')

) as ss3
group by ControlEstate
) as ss4
) as ss5
order by ReadyPct",
    },

#===================

    {
      name: "Watchdog Failure Detail - Prod Kingdoms",
      note: "Excludes SQL queries, puppetChecker, kubeResourcesChecker, and nodeChecker",
      sql: "select *
from (
      select
        Payload->>'$.status.report.CheckerName' as CheckerName,
        CAST(ControlEstate as CHAR CHARACTER SET utf8) AS ControlEstate,
        CAST(upper(substr(ControlEstate,1,3)) as CHAR CHARACTER SET utf8) AS Kingdom,
        Payload->>'$.status.report.Success' as Success,
        Payload->>'$.status.report.ReportCreatedAt' as ReportCreatedAt,
        FLOOR(TIME_TO_SEC(TIMEDIFF(UTC_TIMESTAMP(), STR_TO_DATE(Payload->>'$.status.report.ReportCreatedAt', '%Y-%m-%dT%H:%i:%s.')))/60.0) as ReportAgeInMinutes,
        Payload->>'$.status.report.Instance' as Instance,
        case when Payload->>'$.status.report.ErrorMessage' = 'null' then null else Payload->>'$.status.report.ErrorMessage' end as Error,
        Payload->>'$.status.report.Hostname' as HostName,
        Payload->>'$.status.updateWindowInMin' as updateWindowInMin
      from k8s_resource
      where ApiKind = 'WatchDog'
) as ss
where
  not Error is null
  and (Kingdom != 'PRD' and Kingdom != 'XRD')
  and CheckerName != 'puppetChecker' and CheckerName != 'kubeResourcesChecker' and CheckerName != 'nodeChecker' and CheckerName not like 'Sql%'
order by CheckerName, Kingdom, ReportAgeInMinutes",
    },

#===================

    {
      name: "Watchdog Failure Detail - RnD Kingdoms",
      note: "Excludes SQL queries, puppetChecker, kubeResourcesChecker, and nodeChecker",
      sql: "select *
from (
      select
        Payload->>'$.status.report.CheckerName' as CheckerName,
        CAST(ControlEstate as CHAR CHARACTER SET utf8) AS ControlEstate,
        CAST(upper(substr(ControlEstate,1,3)) as CHAR CHARACTER SET utf8) AS Kingdom,
        Payload->>'$.status.report.Success' as Success,
        Payload->>'$.status.report.ReportCreatedAt' as ReportCreatedAt,
        FLOOR(TIME_TO_SEC(TIMEDIFF(UTC_TIMESTAMP(), STR_TO_DATE(Payload->>'$.status.report.ReportCreatedAt', '%Y-%m-%dT%H:%i:%s.')))/60.0) as ReportAgeInMinutes,
        Payload->>'$.status.report.Instance' as Instance,
        case when Payload->>'$.status.report.ErrorMessage' = 'null' then null else Payload->>'$.status.report.ErrorMessage' end as Error,
        Payload->>'$.status.report.Hostname' as HostName,
        Payload->>'$.status.updateWindowInMin' as updateWindowInMin
      from k8s_resource
      where ApiKind = 'WatchDog'
) as ss
where
  not Error is null
  and (Kingdom = 'PRD' or Kingdom = 'XRD')
  and CheckerName != 'puppetChecker' and CheckerName != 'kubeResourcesChecker' and CheckerName != 'nodeChecker' and CheckerName not like 'Sql%'
order by CheckerName, Kingdom, ReportAgeInMinutes",
    },

#===================
# # Single SQL query
#
#    {
#      name: "",
#      note: "".
#      sql: "",
#    },

#===================
# # Multi-sql query
#
#    {
#      name: "",
#      note: "",
#      multisql: [
#        {
#          name: "",
#          note: "",
#          sql: "",
#        }
#      ],
#    }

  ],
}
