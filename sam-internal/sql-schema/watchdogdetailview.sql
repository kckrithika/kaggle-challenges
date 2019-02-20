CREATE ALGORITHM=UNDEFINED DEFINER=`duncans`@`%` SQL SECURITY DEFINER VIEW `watchdogdetailview` AS
SELECT `watchdogstatus`.`NAME` AS `NAME`,
       `watchdogstatus`.`controlestate` AS `controlestate`,
       `watchdogstatus`.`kingdom` AS `kingdom`,
       `watchdogstatus`.`CheckerName` AS `containerruntimeversion`,
       `watchdogstatus`.`Description` AS `kernelversion`,
       `watchdogstatus`.`ErrorMessage` AS `kubeletversion`,
       `watchdogstatus`.`Hostname` AS `osimage`,
       `watchdogstatus`.`AdditionalEmailRecipients` AS `AdditionalEmailRecipients`,
       `watchdogstatus`.`Hostname` AS `Hostname`,
       `watchdogstatus`.`Instance` AS `Instance`,
       `nodeconditions`.`outofdisk` AS `outofdisk`,
       `nodeconditions`.`memorypressure` AS `memorypressure`,
       `nodeconditions`.`diskpressure` AS `diskpressure`,
       `nodeconditions`.`ready` AS `ready`
FROM ((
         (SELECT `sam_kube_resource`.`k8s_resource`.`Name` AS `NAME`,
                 `sam_kube_resource`.`k8s_resource`.`ControlEstate` AS `controlestate`,
                 substr(`sam_kube_resource`.`k8s_resource`.`ControlEstate`,1,3) AS `kingdom`,
                 trim(BOTH '"'
                      FROM json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.status.report.CheckerName')) AS `CheckerName`,
                 trim(BOTH '"'
                      FROM json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.status.report.Description')) AS `Description`,
                 trim(BOTH '"'
                      FROM json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.status.report.ErrorMessage')) AS `ErrorMessage`,
                 trim(BOTH '"'
                      FROM json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.status.report.AdditionalEmailRecipients')) AS `AdditionalEmailRecipients`,
                 trim(BOTH '"'
                      FROM json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.status.Hostname')) AS `Hostname`,
                 trim(BOTH '"'
                      FROM json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.status.Instance')) AS `Instance`
          FROM `sam_kube_resource`.`k8s_resource`
          WHERE ((`sam_kube_resource`.`k8s_resource`.`ApiKind` = 'WatchDog')
                 AND (`sam_kube_resource`.`k8s_resource`.`IsTombstone` = 0)))) `watchdogstatus`
      JOIN
        (SELECT `ss2`.`NAME` AS `NAME`,
                max((CASE WHEN (`ss2`.`condtype` = 'OutOfDisk') THEN `ss2`.`condstatus` ELSE '' END)) AS `outofdisk`,
                max((CASE WHEN (`ss2`.`condtype` = 'MemoryPressure') THEN `ss2`.`condstatus` ELSE '' END)) AS `memorypressure`,
                max((CASE WHEN (`ss2`.`condtype` = 'DiskPressure') THEN `ss2`.`condstatus` ELSE '' END)) AS `diskpressure`,
                max((CASE WHEN (`ss2`.`condtype` = 'Ready') THEN `ss2`.`condstatus` ELSE '' END)) AS `ready`
         FROM
           (SELECT `ss`.`NAME` AS `NAME`,
                   trim(BOTH '"'
                        FROM json_extract(`ss`.`conditions`,concat('$[',`ss`.`n`,'].type'))) AS `condtype`,
                   trim(BOTH '"'
                        FROM json_extract(`ss`.`conditions`,concat('$[',`ss`.`n`,'].status'))) AS `condstatus`
            FROM
              (SELECT `num`.`n` AS `n`,
                      `cond`.`NAME` AS `NAME`,
                      `cond`.`conditions` AS `conditions`
               FROM ((
                        (SELECT '0' AS `n`)
                      UNION
                      SELECT '1' AS `n`
                      UNION
                      SELECT '2' AS `n`
                      UNION
                      SELECT '3' AS `n`
                      UNION
                      SELECT '4' AS `n`
                      UNION
                      SELECT '5' AS `n`
                      UNION
                      SELECT '6' AS `n`) `num`
                     JOIN
                       (SELECT `sam_kube_resource`.`k8s_resource`.`Name` AS `NAME`,
                               json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.status.conditions') AS `conditions`
                        FROM `sam_kube_resource`.`k8s_resource`
                        WHERE ((`sam_kube_resource`.`k8s_resource`.`ApiKind` = 'Node')
                               AND (`sam_kube_resource`.`k8s_resource`.`IsTombstone` = 0))) `cond`)) `ss`) `ss2`
         GROUP BY `ss2`.`NAME`) `nodeconditions` on((`watchdogstatus`.`Hostname` = convert(`nodeconditions`.`NAME` USING utf8mb4))));

