alter VIEW `nodeDetailView` AS
SELECT `nodeStatus`.`Name` AS `Name`,
       `nodeStatus`.`ControlEstate` AS `ControlEstate`,
       `nodeStatus`.`Kingdom` AS `Kingdom`,
       `nodeStatus`.`containerRuntimeVersion` AS `containerRuntimeVersion`,
       `nodeStatus`.`kernelVersion` AS `kernelVersion`,
       `nodeStatus`.`kubeletVersion` AS `kubeletVersion`,
       `nodeStatus`.`osImage` AS `osImage`,
       `nodeStatus`.`address` AS `address`,
       `nodeStatus`.`capacityCpu` AS `capacityCpu`,
       `nodeStatus`.`capacityMemory` AS `capacityMemory`,
       `nodeStatus`.`capacityPods` AS `capacityPods`,
       `nodeStatus`.`MinionPool` AS `MinionPool`,
       `nodeStatus`.`Unschedulable` AS `Unschedulable`,
       `nodeStatus`.`KubeDashboardUrl` AS `KubeDashboardUrl`,
       `nodeConditions`.`OutOfDisk` AS `OutOfDisk`,
       `nodeConditions`.`MemoryPressure` AS `MemoryPressure`,
       `nodeConditions`.`DiskPressure` AS `DiskPressure`,
       `nodeConditions`.`Ready` AS `Ready`
FROM ((
         (SELECT `sam_kube_resource`.`k8s_resource`.`Name` AS `Name`,
                 `sam_kube_resource`.`k8s_resource`.`ControlEstate` AS `ControlEstate`,
                 substr(`sam_kube_resource`.`k8s_resource`.`ControlEstate`,1,3) AS `Kingdom`,
                 trim(BOTH '"'
                      FROM json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.status.nodeInfo.containerRuntimeVersion')) AS `containerRuntimeVersion`,
                 trim(BOTH '"'
                      FROM json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.status.nodeInfo.kernelVersion')) AS `kernelVersion`,
                 trim(BOTH '"'
                      FROM json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.status.nodeInfo.kubeletVersion')) AS `kubeletVersion`,
                 trim(BOTH '"'
                      FROM json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.status.nodeInfo.osImage')) AS `osImage`,
                 trim(BOTH '"'
                      FROM json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.status.addresses[0].address')) AS `address`,
                 trim(BOTH '"'
                      FROM json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.status.capacity.cpu')) AS `capacityCpu`,
                 trim(BOTH '"'
                      FROM json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.status.capacity.memory')) AS `capacityMemory`,
                 trim(BOTH '"'
                      FROM json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.status.capacity.pods')) AS `capacityPods`,
                 json_unquote(json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.metadata.labels.pool')) AS `MinionPool`,
                 json_unquote(json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.spec.unschedulable')) AS `Unschedulable`,
                 concat('http://dashboard-',substr(`sam_kube_resource`.`k8s_resource`.`ControlEstate`,1,3),'-sam.csc-sam.prd-sam.prd.slb.sfdc.net/#!/node/',`sam_kube_resource`.`k8s_resource`.`Name`,'?namespace=default') AS `KubeDashboardUrl`
          FROM `sam_kube_resource`.`k8s_resource`
          WHERE ((`sam_kube_resource`.`k8s_resource`.`ApiKind` = 'Node')
                 AND (`sam_kube_resource`.`k8s_resource`.`IsTombstone` = 0)))) `nodeStatus`
      JOIN
        (SELECT `ss2`.`Name` AS `Name`,
                max((CASE WHEN (`ss2`.`CondType` = 'OutOfDisk') THEN `ss2`.`CondStatus` ELSE '' END)) AS `OutOfDisk`,
                max((CASE WHEN (`ss2`.`CondType` = 'MemoryPressure') THEN `ss2`.`CondStatus` ELSE '' END)) AS `MemoryPressure`,
                max((CASE WHEN (`ss2`.`CondType` = 'DiskPressure') THEN `ss2`.`CondStatus` ELSE '' END)) AS `DiskPressure`,
                max((CASE WHEN (`ss2`.`CondType` = 'Ready') THEN `ss2`.`CondStatus` ELSE '' END)) AS `Ready`
         FROM
           (SELECT `ss`.`Name` AS `Name`,
                   trim(BOTH '"'
                        FROM json_extract(`ss`.`Conditions`,concat('$[',`ss`.`n`,'].type'))) AS `CondType`,
                   trim(BOTH '"'
                        FROM json_extract(`ss`.`Conditions`,concat('$[',`ss`.`n`,'].status'))) AS `CondStatus`
            FROM
              (SELECT `num`.`n` AS `n`,
                      `cond`.`Name` AS `Name`,
                      `cond`.`Conditions` AS `Conditions`
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
                       (SELECT `sam_kube_resource`.`k8s_resource`.`Name` AS `Name`,
                               json_extract(`sam_kube_resource`.`k8s_resource`.`Payload`,'$.status.conditions') AS `Conditions`
                        FROM `sam_kube_resource`.`k8s_resource`
                        WHERE ((`sam_kube_resource`.`k8s_resource`.`ApiKind` = 'Node')
                               AND (`sam_kube_resource`.`k8s_resource`.`IsTombstone` = 0))) `cond`)) `ss`) `ss2`
         GROUP BY `ss2`.`Name`) `nodeConditions` on((`nodeStatus`.`Name` = `nodeConditions`.`Name`)));

