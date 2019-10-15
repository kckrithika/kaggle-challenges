{
    bedhealth(type, bed) :: {
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
        case when (Message like 'Node % which was running pod % is unresponsive') then 'YELLOW' else 'RED' end as Status,
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
        and Phase <> 'Failed'
        and Name not like '%slb%'
        and Name not like '%sdn%'",
              },

              # ===

              {
                name: "Watchdog failures",
                note: "For phased releases, items in red should be fixed.",
                sql: "select * from (
        select
        case when SUM(FailureCount)=0 then '' when CheckerName in ('puppetChecker', 'kubeResourcesChecker', 'nodeChecker', 'deploymentChecker') then 'YELLOW' else 'RED' end as Status,
        CheckerName,
        SUM(SuccessCount) as SuccessCount,
        SUM(FailureCount) as FailureCount,
        SUM(SuccessCount)/(SUM(SuccessCount)+SUM(FailureCount)) as SuccessPct,
        MIN(ReportAgeInMinutes) as ReportAgeInMinutes,
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
        case when Payload->>'$.status.report.ErrorMessage' = 'null' then null else
          case when Payload->>'$.status.report.CheckerName' like 'cliChecker%' then
            concat(Payload->>'$.status.report.Hostname', ': ', Payload->>'$.status.report.ErrorMessage')
          else
            Payload->>'$.status.report.ErrorMessage'
          end
        end as Error,
        TIMESTAMPDIFF(MINUTE, STR_TO_DATE(Payload->>'$.status.report.ReportCreatedAt', '%Y-%m-%dT%H:%i:%s.'), UTC_TIMESTAMP()) as ReportAgeInMinutes
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
            LEAST(FLOOR(PodAgeInMinutes/60.0/24.0),5) as PodAgeDays,
            1 as Count
          from podDetailView
          where IsSamApp = True and ProduceAgeInMinutes<60 and name not like 'syntheticwd%'
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
        ) as ss
        where PodAgeDays IS NOT NULL
        group by ControlEstate, PodAgeDays
      ) as ss2
      group by ControlEstate, PodAgeDays",
              },

              # ===

              {
                name: "List of customer pods ordered by PodAge (top 20)",
                sql: "select
            case when (LEAST(FLOOR(PodAgeInMinutes/60.0/24.0),10)<2) then 'YELLOW' else '' end as Status,
            Name,
            Namespace,
            ControlEstate,
            LEAST(FLOOR(PodAgeInMinutes/60.0/24.0),10) as PodAgeDays,
            Phase
          from podDetailView
          where IsSamApp = True and ProduceAgeInMinutes<60 and Phase = 'Running' and Phase != 'Failed' and name not like 'syntheticwd%' and namespace not like 'e2e-%'
          and ControlEstate = '" + bed + "'
          order by PodAgeDays
          limit 20",
              },

             # ===

             {
               name: "Unhealthy customer pods (top 20)",
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
and ControlEstate = '" + bed + "' and Phase != 'Running' and Phase != 'Failed' and name not like 'syntheticwd%'
limit 20",
            },

    ],
    }
}
