alter VIEW `podDetailView` AS
SELECT `ControlEstate` AS `ControlEstate`,
       `Namespace` AS `Namespace`,
       `Name` AS `Name`,
       json_unquote(json_extract(`Payload`,'$.spec.nodeName')) AS `NodeName`,
       json_unquote(json_extract(`Payload`,'$.status.phase')) AS `Phase`,
       json_unquote(json_extract(`Payload`,'$.status.message')) AS `Message`,
       json_unquote(json_extract(`Payload`,'$.metadata.labels."sam.data.sfdc.net/owner"')) AS `ownerLabel`,
       substr(`ControlEstate`,1,3) AS `Kingdom`,
       concat('http://dashboard-',substr(`ControlEstate`,1,3),'-sam.csc-sam.prd-sam.prd.slb.sfdc.net/#!/pod/',`Namespace`,'/',`Name`,'?namespace=',`Namespace`) AS `PodUrl`,
       concat('http://dashboard-',convert(substr(`ControlEstate`,1,3) USING utf8),'-sam.csc-sam.prd-sam.prd.slb.sfdc.net/#!/node/',cast(json_unquote(json_extract(`Payload`,'$.spec.nodeName')) AS char charset utf8),'?namespace=default') AS `NodeUrl`,
       (CASE
            WHEN isnull(json_unquote(json_extract(`Payload`,'$.metadata.labels.sam_app'))) THEN FALSE
            ELSE TRUE
        END) AS `IsSamApp`,
       str_to_date(json_unquote(json_extract(`Payload`,'$.status.startTime')),'%Y-%m-%dT%H:%i:%sZ') AS `PodStartTime`,
       floor((time_to_sec(timediff(utc_timestamp(),str_to_date(json_unquote(json_extract(`Payload`,'$.status.startTime')),'%Y-%m-%dT%H:%i:%sZ'))) / 60.0)) AS `PodAgeInMinutes`,
       from_unixtime((`ConsumeTime` / 1000000000.0)) AS `ConsumeTimestamp`,
       from_unixtime((`ProduceTime` / 1000000000.0)) AS `ProduceTimestamp`,
       (time_to_sec(timediff(utc_timestamp(),from_unixtime((`ProduceTime` / 1000000000.0)))) / 60.0) AS `ProduceAgeInMinutes`,
       (time_to_sec(timediff(utc_timestamp(),from_unixtime((`ConsumeTime` / 1000000000.0)))) / 60.0) AS `ConsumeAgeInMinutes`,
       `Payload` AS `Payload`
FROM `k8s_resource`
WHERE ((`ApiKind` = 'Pod')
       AND (`IsTombstone` = 0));

