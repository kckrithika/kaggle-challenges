alter VIEW `deploymentDetailView` AS
SELECT `ControlEstate` AS `control_estate`,
       `Namespace` AS `namespace`,
       `Name` AS `name`,
       `ApiKind` AS `type`,
       json_unquote(json_extract(`Payload`,'$.metadata.uid')) AS `uid`,
       json_unquote(json_extract(`Payload`,'$.metadata.name')) AS `deployment_name`,
       json_unquote(json_extract(`Payload`,'$.metadata.labels.sam_app')) AS `app_name`,
       (CASE
            WHEN isnull(json_unquote(json_extract(`Payload`,'$.metadata.annotations."titleLine"'))) THEN json_unquote(json_extract(`Payload`,'$.metadata.annotations.\"smb.sam.data.sfdc.net/titleLine\"'))
            ELSE json_unquote(json_extract(`Payload`,'$.metadata.annotations."titleLine"'))
        END) AS `last_commit_message`,
        (CASE
            WHEN isnull(json_unquote(json_extract(`Payload`,'$.metadata.annotations."commitSHA1"'))) THEN json_unquote(json_extract(`Payload`,'$.metadata.annotations.\"smb.sam.data.sfdc.net/commitSHA1\"'))
            ELSE json_unquote(json_extract(`Payload`,'$.metadata.annotations."commitSHA1"'))
        END) AS `commit_sha1`,
       json_unquote(json_extract(`Payload`,'$.metadata.labels.sam_function')) AS `sam_function`,
       json_unquote(json_extract(`Payload`,'$.metadata.labels.sam_app')) AS `sam_app`,
       json_unquote(json_extract(`Payload`,'$.spec.replicas')) AS `desired_replicas`,
       json_unquote(json_extract(`Payload`,'$.status.replicas')) AS `replicas`,
       json_unquote(json_extract(`Payload`,'$.status.availableReplicas')) AS `available_replicas`,
       json_unquote(json_extract(`Payload`,'$.status.unavailableReplicas')) AS `unavailable_replicas`,
       json_unquote(json_extract(`Payload`,'$.status.updatedReplicas')) AS `updated_replicas`,
       json_unquote(json_extract(`Payload`,'$.status.readyReplicas')) AS `ready_replicas`,
       json_unquote(json_extract(`Payload`,'$.status.conditions[0].message')) AS `message`,
       json_unquote(json_extract(`Payload`,'$.metadata.labels."sam.data.sfdc.net/owner"')) AS `ownerLabel`,
       substr(`ControlEstate`,1,3) AS `kingdom`,
       (CASE `ControlEstate`
            WHEN 'prd-samtest' THEN ''
            WHEN 'prd-samdev' THEN ''
            ELSE concat('http://dashboard-',substr(`ControlEstate`,1,3),'-sam.csc-sam.prd-sam.prd.slb.sfdc.net/#!/',lower(`ApiKind`),'/',`Namespace`,'/',`Name`,'?namespace=',`Namespace`)
        END) AS `k8s_portal_deployment_url`,
       concat('https://argus-ui.data.sfdc.net/argus/#/dashboards/895452?start=-1h&end=-0h&kingdom=',`ControlEstate`,'&namespace=',`Namespace`,'&deploymentName=',`Name`) AS `argus_url`,
       (CASE
            WHEN isnull(json_unquote(json_extract(`Payload`,'$.metadata.labels.sam_app'))) THEN FALSE
            ELSE TRUE
        END) AS `is_sam_app`,
       floor((time_to_sec(timediff(utc_timestamp(),str_to_date(json_unquote(json_extract(`Payload`,'$.metadata.creationTimestamp')),'%Y-%m-%dT%H:%i:%sZ'))) / 60.0)) AS `deployment_age_in_minutes`,
       from_unixtime((`ConsumeTime` / 1000000000.0)) AS `consume_timestamp`,
       from_unixtime((`ProduceTime` / 1000000000.0)) AS `produce_timestamp`,
       (time_to_sec(timediff(utc_timestamp(),from_unixtime((`ProduceTime` / 1000000000.0)))) / 60.0) AS `produce_age_in_minutes`,
       (time_to_sec(timediff(utc_timestamp(),from_unixtime((`ConsumeTime` / 1000000000.0)))) / 60.0) AS `consume_age_in_minutes`,
       `Payload` AS `payload`
FROM `k8s_resource`
WHERE (((`ApiKind` = 'Deployment')
        OR (`ApiKind` = 'StatefulSet'))
       AND (`IsTombstone` = 0));

