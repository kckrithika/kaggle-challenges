{
            name: "Host Repair",
            multisql: [
                   {
                        name: "Hosts rebooted in last 7 days",
                        note: "All Hosts rebooted in last 14 days.  Healty indicates if the host is currently healthy.",
                        sql: "select
  name,
  controlEstate,
  Payload->>'$.status.details.totalRebootCount' as TotalRebootCount,
  Payload->>'$.observation.healthInfo.health' as Healthy,
  Payload->>'$.spec.startTime' as LastRebootTime
from k8s_resource
where ApiKind = 'HostRepair' and (TIMESTAMPDIFF(MINUTE, STR_TO_DATE(Payload->>'$.spec.startTime','%Y-%m-%dT%H:%i:%s'), NOW())/60.0/24.0)<14
",
                    },
            ],
    }
