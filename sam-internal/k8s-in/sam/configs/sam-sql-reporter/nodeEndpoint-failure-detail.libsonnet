{
        name: "NodeEnpoint-failure-detail",
        sql: "select 
                TRIM('connectivitylabelerchecker-' FROM name) as HostName,
                Payload->>'$.status.report.Target' as Target, 
                Payload->>'$.status.report.Success' as Connectivity, 
                TIMESTAMPDIFF(MINUTE, STR_TO_DATE(Payload->>'$.status.report.ReportCreatedAt', '%Y-%m-%dT%H:%i:%s.'), UTC_TIMESTAMP()) as ReportAgeInMinutes,
                Payload->>'$.status.report.ErrorMessage' as ErrorMsg
        from 
                k8s_resource 
        where 
                apikind = 'watchdog' and 
                name like 'connectivitylabelerchecker-%' and 
                Payload->>'$.status.report.Success' = 'false'",
}
