alter VIEW `serviceDetailView` AS
SELECT `k8s_resource`.`ControlEstate` AS `control_estate`,
       `k8s_resource`.`Namespace` AS `namespace`,
       `k8s_resource`.`Name` AS `name`,
       `k8s_resource`.`ApiKind` AS `type`,
       json_unquote(json_extract(`k8s_resource`.`Payload`,'$.metadata.uid')) AS `uid`,
       json_unquote(json_extract(`k8s_resource`.`Payload`,'$.metadata.annotations.commitSHA1')) AS `commit_sha1`,
       json_unquote(json_extract(`k8s_resource`.`Payload`,'$.metadata.annotations."slb.sfdc.net/name"')) AS `slb_name`,
       json_unquote(json_extract(`k8s_resource`.`Payload`,'$.metadata.labels.sam_app')) AS `sam_app`,
       json_unquote(json_extract(`k8s_resource`.`Payload`,'$.metadata.labels.sam_function')) AS `sam_function`,
       json_unquote(json_extract(`k8s_resource`.`Payload`,'$.metadata.labels.sam_loadbalancer')) AS `sam_loadbalancer`,
       json_unquote(json_extract(`Payload`,'$.metadata.labels."sam.data.sfdc.net/owner"')) AS `ownerLabel`,
       floor((time_to_sec(timediff(utc_timestamp(),str_to_date(json_unquote(json_extract(`k8s_resource`.`Payload`,'$.metadata.creationTimestamp')),'%Y-%m-%dT%H:%i:%sZ'))) / 60.0)) AS `service_age_in_minutes`,
       from_unixtime((`k8s_resource`.`ConsumeTime` / 1000000000.0)) AS `consume_timestamp`,
       from_unixtime((`k8s_resource`.`ProduceTime` / 1000000000.0)) AS `produce_timestamp`,
       (time_to_sec(timediff(utc_timestamp(),from_unixtime((`k8s_resource`.`ProduceTime` / 1000000000.0)))) / 60.0) AS `produce_age_in_minutes`,
       (time_to_sec(timediff(utc_timestamp(),from_unixtime((`k8s_resource`.`ConsumeTime` / 1000000000.0)))) / 60.0) AS `consume_age_in_minutes`,
       `k8s_resource`.`Payload` AS `payload`
FROM `k8s_resource`
WHERE (`k8s_resource`.`ApiKind` = 'Service');

