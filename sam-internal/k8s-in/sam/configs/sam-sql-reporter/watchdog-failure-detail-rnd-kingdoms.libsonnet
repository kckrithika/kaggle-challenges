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
        TIMESTAMPDIFF(MINUTE, STR_TO_DATE(Payload->>'$.status.report.ReportCreatedAt', '%Y-%m-%dT%H:%i:%s.'), UTC_TIMESTAMP()) as ReportAgeInMinutes,
        case when TIMESTAMPDIFF(MINUTE, STR_TO_DATE(Payload->>'$.status.report.ReportCreatedAt', '%Y-%m-%dT%H:%i:%s.'), UTC_TIMESTAMP())>90 then 'YELLOW' else '' end as Stale,
        Payload->>'$.status.report.Instance' as Instance,
        case when Payload->>'$.status.report.ErrorMessage' = 'null' then null else Payload->>'$.status.report.ErrorMessage' end as Error,
        Payload->>'$.status.report.Hostname' as HostName,
        Payload->>'$.status.updateWindowInMin' as updateWindowInMin
      from k8s_resource
      where ApiKind = 'WatchDog'
) as ss
where
  not Error is null
  and Success != 'true'
  and (Kingdom = 'PRD' or Kingdom = 'XRD')
  and CheckerName != 'puppetChecker' and CheckerName != 'kubeResourcesChecker' and CheckerName != 'nodeChecker' and CheckerName not like 'Sql%'
  and Instance not like '%samminionceph%'
  and Stale = ''
order by CheckerName, Kingdom, ReportAgeInMinutes",
    }
