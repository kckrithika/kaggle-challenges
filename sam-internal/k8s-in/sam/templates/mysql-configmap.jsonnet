local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "prd-samtwo" || configs.estate == "prd-data-flowsnake" then {
    data: {
        "backup.cnf": |||
        # Apply this config only on backup system
        # To host a backup from a given day _ set datadir to /var/lib/mysql_30 (for the 30th)
        [mysql]
        #datadir=/var/lib/mysql/mysql
        #socket=/var/lib/mysql/mysql.sock
        [mysqld]
        log_bin
        #datadir=/var/lib/mysql/mysql
        #socket=/var/lib/mysql/mysql.sock
|||,
        "master.cnf": |||
        # Apply this config only on the master.
        [mysqld]
        # Configs specific to master
        skip-log-bin
        binlog_stmt_cache_size=1G
        expire_logs_days=1
        sync_binlog=0
        binlog_row_image=minimal
        binlog_format=MIXED
        # For a detailed explanation of these
        # vars, see https://git.soma.salesforce.com/sam/sam/wiki/MySQL_Performance_Tuning
        innodb_buffer_pool_size=16GiB
        innodb_change_buffer_max_size=50
        innodb_flush_log_at_trx_commit=1 
        innodb_io_capacity=400
        innodb_log_buffer_size=1GiB
        innodb_lock_wait_timeout=10
        bulk_insert_buffer_size=128MiB
        tmp_table_size=1GiB
        max_heap_table_size=1GiB
        skip_name_resolve=1

|||,
        "slave.cnf": |||
        # Apply this config only on slaves.
        [mysqld]
        # Configs specific to replication slaves
        super-read-only
        slave_parallel_workers=128
        slave_pending_jobs_size_max=1GiB
        slave_compressed_protocol=1
        slave_exec_mode=IDEMPOTENT
        # For a detailed explanation of these
        # vars, see https://git.soma.salesforce.com/sam/sam/wiki/MySQL_Performance_Tuning
        innodb_buffer_pool_size=16GiB
        innodb_change_buffer_max_size=50
        innodb_flush_log_at_trx_commit=1 
        innodb_io_capacity=400
        innodb_log_buffer_size=1GiB
        innodb_lock_wait_timeout=10
        bulk_insert_buffer_size=128MiB
        tmp_table_size=1GiB
        max_heap_table_size=1GiB
        skip_name_resolve=1
|||,
        "schema.sql": |||
        CREATE DATABASE IF NOT EXISTS `sam_kube_resource`;
        USE sam_kube_resource;

        CREATE TABLE IF NOT EXISTS `k8s_resource` (
          `ControlEstate` varchar(255) NOT NULL,
          `Namespace` varchar(255) NOT NULL DEFAULT 'default',
          `ApiVersion` varchar(255) DEFAULT NULL,
          `ApiGroup` varchar(255) DEFAULT NULL,
          `ApiKind` varchar(255) NOT NULL,
          `Name` varchar(255) NOT NULL,
          `Payload` json NOT NULL,
          `ProduceTime` bigint(20) NOT NULL,
          `ConsumeTime` bigint(20) NOT NULL,
          `IsTombstone` tinyint(1) DEFAULT NULL,
          PRIMARY KEY (`ControlEstate`,`Namespace`,`ApiKind`,`Name`)
        ) ENGINE=InnoDB DEFAULT CHARSET=latin1;

        CREATE TABLE IF NOT EXISTS `PoolMaps` (
          `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
          `created_at` timestamp NULL DEFAULT NULL,
          `updated_at` timestamp NULL DEFAULT NULL,
          `deleted_at` timestamp NULL DEFAULT NULL,
          `checksum` varchar(255) DEFAULT NULL,
          `file_path` varchar(4096) DEFAULT NULL,
          `app_name` varchar(255) NOT NULL,
          `pool_name` varchar(255) NOT NULL,
          `team_or_user` varchar(255) NOT NULL,
          `is_team` tinyint(1) NOT NULL,
          PRIMARY KEY (`id`),
          KEY `idx_PoolMaps_deleted_at` (`deleted_at`)
        ) ENGINE=InnoDB AUTO_INCREMENT=855 DEFAULT CHARSET=latin1;

        CREATE TABLE IF NOT EXISTS `PullRequests` (
          `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
          `created_at` timestamp NULL DEFAULT NULL,
          `updated_at` timestamp NULL DEFAULT NULL,
          `deleted_at` timestamp NULL DEFAULT NULL,
          `pr_num` int(11) NOT NULL,
          `pr_url` varchar(255) DEFAULT NULL,
          `author` varchar(255) DEFAULT NULL,
          `authorized_by` varchar(255) DEFAULT NULL,
          `subject` varchar(1024) DEFAULT NULL,
          `git_hash` varchar(255) DEFAULT NULL,
          `evaluate_pr_status` varchar(255) DEFAULT NULL,
          `pr_last_modified` timestamp NULL DEFAULT NULL,
          `state` varchar(255) DEFAULT NULL,
          `created_time` timestamp NULL DEFAULT NULL,
          `first_approval_link_posted_time` timestamp NULL DEFAULT NULL,
          `merged_time` timestamp NULL DEFAULT NULL,
          `most_recent_approval_link_posted_time` timestamp NULL DEFAULT NULL,
          `most_recent_authorized_time` timestamp NULL DEFAULT NULL,
          `most_recent_evaluate_pr_completion_time` timestamp NULL DEFAULT NULL,
          PRIMARY KEY (`id`),
          UNIQUE KEY `pr_num` (`pr_num`),
          KEY `idx_PullRequests_deleted_at` (`deleted_at`)
        ) ENGINE=InnoDB AUTO_INCREMENT=222 DEFAULT CHARSET=latin1;

        CREATE TABLE IF NOT EXISTS `PullRequestToTeamOrUser` (
          `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
          `created_at` timestamp NULL DEFAULT NULL,
          `updated_at` timestamp NULL DEFAULT NULL,
          `deleted_at` timestamp NULL DEFAULT NULL,
          `pr_num` int(11) NOT NULL,
          `app_name` varchar(255) NOT NULL,
          `pool_name` varchar(255) NOT NULL,
          `team_or_user` varchar(255) NOT NULL,
          `is_team` tinyint(1) NOT NULL,
          PRIMARY KEY (`id`),
          KEY `idx_PullRequestToTeamOrUser_deleted_at` (`deleted_at`)
        ) ENGINE=InnoDB AUTO_INCREMENT=125 DEFAULT CHARSET=latin1;

        CREATE TABLE IF NOT EXISTS `TNRPManifestData` (
          `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
          `created_at` timestamp NULL DEFAULT NULL,
          `updated_at` timestamp NULL DEFAULT NULL,
          `deleted_at` timestamp NULL DEFAULT NULL,
          `git_hash` varchar(64) NOT NULL,
          `manifest_zip_version` varchar(255) DEFAULT NULL,
          `manifest_zip_time` timestamp NULL DEFAULT NULL,
          PRIMARY KEY (`id`),
          UNIQUE KEY `git_hash` (`git_hash`),
          KEY `idx_TNRPManifestData_deleted_at` (`deleted_at`)
        ) ENGINE=InnoDB AUTO_INCREMENT=904 DEFAULT CHARSET=latin1;


        CREATE TABLE IF NOT EXISTS `crd_history` (
          `ControlEstate` varchar(255) NOT NULL,
          `Namespace` varchar(255) NOT NULL DEFAULT 'default',
          `ApiKind` varchar(255) NOT NULL,
          `Name` varchar(255) NOT NULL,
          `PoolName` varchar(255) NOT NULL,
          `PRNum` int(11) DEFAULT NULL,
          `Payload` json NOT NULL,
          `ApiVersion` varchar(255) DEFAULT NULL,
          `ApiGroup` varchar(255) DEFAULT NULL,
          `ProduceTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
          `ConsumeTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (`ControlEstate`,`Namespace`,`ApiKind`,`Name`,`PoolName`)
        ) ENGINE=InnoDB DEFAULT CHARSET=latin1;

        CREATE TABLE IF NOT EXISTS `consume` (
          `Topic` varchar(255) NOT NULL,
          `GroupName` varchar(255) NOT NULL,
          `KafkaPartition` int(11) NOT NULL DEFAULT '0',
          `KafkaOffset` bigint(20) NOT NULL,
          PRIMARY KEY (`Topic`,`GroupName`,`KafkaPartition`)
        ) ENGINE=InnoDB DEFAULT CHARSET=latin1;

        CREATE TABLE IF NOT EXISTS `Pools` (
          `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
          `created_at` timestamp NULL DEFAULT NULL,
          `updated_at` timestamp NULL DEFAULT NULL,
          `deleted_at` timestamp NULL DEFAULT NULL,
          `checksum` varchar(255) NOT NULL,
          `file_path` varchar(4096) NOT NULL,
          `pool_name` varchar(255) NOT NULL,
          `access` varchar(4096) NOT NULL,
          `control_estate` varchar(255) NOT NULL,
          `super_pod` varchar(255) DEFAULT NULL,
          PRIMARY KEY (`id`),
          KEY `idx_Pools_deleted_at` (`deleted_at`)
        ) ENGINE=InnoDB AUTO_INCREMENT=170 DEFAULT CHARSET=latin1;

        create or replace view `deploymentDetailView` AS
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

        create or replace view  `crd_status_view` AS
            SELECT
               `app`.`appname`          AS `appName`,
               `app`.`namespace`        AS `Namespace`,
               `app`.`controlestate`    AS `ControlEstate`,
               `app`.`samappmsg`        AS `samappMsg`,
               `bundle`.`bundlename`    AS `bundleName`,
               `bundle`.`bundleid`      AS `bundleId`,
               `bundle`.`bundlestatus`  AS `bundleStatus`,
               `bundle`.`overallstatus` AS `overallStatus`
             FROM ((SELECT
                       `sam_kube_resource`.`k8s_resource`.`name`
                         AS `appName`,
                       `sam_kube_resource`.`k8s_resource`.`namespace`
                         AS `Namespace`,
                       `sam_kube_resource`.`k8s_resource`.`controlestate`
                         AS
                            `ControlEstate`,
                       Json_unquote(Json_extract(`sam_kube_resource`.`k8s_resource`.`payload`, '$.status.message')) AS `samappMsg`
                     FROM `sam_kube_resource`.`k8s_resource`
                     WHERE (`sam_kube_resource`.`k8s_resource`.`apikind` = 'SamApp')) `app`
               LEFT JOIN (SELECT
                            `sam_kube_resource`.`k8s_resource`.`name`
                              AS
                              `bundleName`,
                            Json_unquote(Json_extract(`sam_kube_resource`.`k8s_resource`.`payload`, '$.metadata.uid'))
                              AS
                              `bundleId`,
                            Json_unquote(Json_extract(`sam_kube_resource`.`k8s_resource`.`payload`, '$.status'))
                              AS
                              `bundleStatus`,
                            Json_unquote(Json_extract(`sam_kube_resource`.`k8s_resource`.`payload`, '$.status.state'))
                              AS
                              `overallStatus`
                          FROM `sam_kube_resource`.`k8s_resource`
                          WHERE (`sam_kube_resource`.`k8s_resource`.`apikind` = 'Bundle')) `bundle`
                 ON (`app`.`appname` = `bundle`.`bundlename`));


        create or replace view `nodeDetailView` AS
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

        create or replace view `podDetailView` AS
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

        create or replace view `PoolMapsExpanded` AS
        SELECT `pm`.`id` AS `id`,
               `pm`.`created_at` AS `created_at`,
               `pm`.`updated_at` AS `updated_at`,
               `pm`.`deleted_at` AS `deleted_at`,
               `pm`.`checksum` AS `checksum`,
               `pm`.`file_path` AS `file_path`,
               `pm`.`app_name` AS `app_name`,
               `pm`.`pool_name` AS `pool_name`,
               `pm`.`team_or_user` AS `team_or_user`,
               `pm`.`is_team` AS `is_team`,
               substr(`p`.`control_estate`,5) AS `control_estate`,
               `p`.`control_estate` AS `full_control_estate`,
               `p`.`super_pod` AS `super_pod`,
               `p`.`access` AS `access`
        FROM (`PoolMaps` `pm`
              LEFT JOIN `Pools` `p` on((convert(`pm`.`pool_name` USING utf8mb4) = `p`.`pool_name`)));

        create or replace view `PullRequestByTeam` AS
        SELECT DISTINCT `t`.`pr_num` AS `pr_num`,
                        `t`.`team_or_user` AS `team_or_user`,
                        `t`.`is_team` AS `is_team`,
                        `t`.`app_name` AS `app_name`,
                        `t`.`pool_name` AS `pool_name`,
                        `p`.`state` AS `state`,
                        `p`.`pr_last_modified` AS `pr_last_modified`,
                        `p`.`pr_url` AS `pr_url`,
                        `p`.`author` AS `author`,
                        `p`.`subject` AS `subject`,
                        `p`.`authorized_by` AS `authorized_by`,
                        substr(`pool`.`control_estate`,5) AS `control_estate`,
                        `pool`.`control_estate` AS `full_control_estate`,
                        `pool`.`super_pod` AS `super_pod`,
                        `pool`.`access` AS `access`
        FROM ((`PullRequestToTeamOrUser` `t`
               JOIN `PullRequests` `p` on((`t`.`pr_num` = `p`.`pr_num`)))
              JOIN `Pools` `pool` on((`t`.`pool_name` = `pool`.`pool_name`)));

        create or replace view `PullRequestLatencyView` AS
        SELECT
            `p`.`pr_num` AS `pr_num`,
            `p`.`state` AS `pr_state`,
            `p`.`git_hash` AS `git_hash`,
            `p`.`created_time` AS `created_time`,
            `p`.`most_recent_authorized_time` AS `most_recent_authorized_time`,
            `p`.`merged_time` AS `merged_time`,
            `t`.`manifest_zip_time` AS `manifest_zip_time`,
            STR_TO_DATE( CASE WHEN `c`.`payload` -> '$.status.startTime' = '0001-01-01T00:00:00Z' THEN
                    NULL
                ELSE
                    JSON_UNQUOTE(payload -> '$.status.startTime')
                END, '%Y-%m-%dT%H:%i:%s') AS `deployment_started`,
            STR_TO_DATE( CASE WHEN `c`.`payload` -> '$.status.endTime' = '0001-01-01T00:00:00Z' THEN
                    NULL
                ELSE
                    JSON_UNQUOTE(payload -> '$.status.endTime')
                END, '%Y-%m-%dT%H:%i:%s') AS `deployment_finished`
        FROM (`sam_kube_resource`.`PullRequests` `p`
            LEFT JOIN `sam_kube_resource`.`TNRPManifestData` `t` ON (`p`.`git_hash` = `t`.`git_hash`))
            LEFT OUTER JOIN `sam_kube_resource`.`crd_history` `c` ON `c`.`PRNum` = `p`.`pr_num`
        ORDER BY
            `p`.`merged_time` DESC;

            create or replace view `replicaSetDetailView` AS
        SELECT `ControlEstate` AS `control_estate`,
               `Namespace` AS `namespace`,
               `Name` AS `name`,
               json_unquote(json_extract(`Payload`,'$.metadata.uid')) AS `uid`,
               json_unquote(json_extract(`Payload`,'$.metadata.name')) AS `replica_set_name`,
               json_unquote(json_extract(`Payload`,'$.metadata.ownerReferences[0].uid')) AS `parent_uid`,
               json_unquote(json_extract(`Payload`,'$.metadata.labels.sam_app')) AS `app_name`,
               json_unquote(json_extract(`Payload`,'$.metadata.annotations.titleLine')) AS `last_commit_message`,
               json_unquote(json_extract(`Payload`,'$.metadata.annotations.commitSHA1')) AS `commit_sha1`,
               json_unquote(json_extract(`Payload`,'$.metadata.labels.sam_function')) AS `sam_function`,
               json_unquote(json_extract(`Payload`,'$.metadata.labels.sam_app')) AS `sam_app`,
               json_unquote(json_extract(`Payload`,'$.spec.replicas')) AS `desired_replicas`,
               json_unquote(json_extract(`Payload`,'$.status.replicas')) AS `replicas`,
               json_unquote(json_extract(`Payload`,'$.status.availableReplicas')) AS `available_replicas`,
               json_unquote(json_extract(`Payload`,'$.status.unavailableReplicas')) AS `unavailable_replicas`,
               json_unquote(json_extract(`Payload`,'$.status.readyReplicas')) AS `ready_replicas`,
               json_unquote(json_extract(`Payload`,'$.metadata.labels."sam.data.sfdc.net/owner"')) AS `ownerLabel`,
               substr(`ControlEstate`,1,3) AS `kingdom`,
               (CASE `ControlEstate`
                    WHEN 'prd-samtest' THEN ''
                    WHEN 'prd-samdev' THEN ''
                    ELSE concat('http://dashboard-',substr(`ControlEstate`,1,3),'-sam.csc-sam.prd-sam.prd.slb.sfdc.net/#!/replicaset/',`Namespace`,'/',`Name`,'?namespace=',`Namespace`)
                END) AS `k8s_portal_replica_set_url`,
               (CASE
                    WHEN isnull(json_unquote(json_extract(`Payload`,'$.metadata.labels.sam_app'))) THEN FALSE
                    ELSE TRUE
                END) AS `is_sam_app`,
               from_unixtime((`ConsumeTime` / 1000000000.0)) AS `consume_timestamp`,
               from_unixtime((`ProduceTime` / 1000000000.0)) AS `produce_timestamp`,
               (time_to_sec(timediff(utc_timestamp(),from_unixtime((`ProduceTime` / 1000000000.0)))) / 60.0) AS `produce_age_in_minutes`,
               (time_to_sec(timediff(utc_timestamp(),from_unixtime((`ConsumeTime` / 1000000000.0)))) / 60.0) AS `consume_age_in_minutes`,
               `Payload` AS `payload`
        FROM `k8s_resource`
        WHERE ((`ApiKind` = 'ReplicaSet')
               AND (`IsTombstone` = 0));

        create or replace view `serviceDetailView` AS
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

        create or replace view `watchdogdetailview` AS
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


        create or replace view `deployment_detail_view2` AS
          SELECT    `deployment`.`control_estate`            AS `control_estate`,
                    `deployment`.`namespace`                 AS `namespace`,
                    `deployment`.`NAME`                      AS `NAME`,
                    `deployment`.`type`                      AS `type`,
                    `deployment`.`uid`                       AS `uid`,
                    `deployment`.`deployment_name`           AS `deployment_name`,
                    `deployment`.`app_name`                  AS `app_name`,
                    `deployment`.`last_commit_message`       AS `last_commit_message`,
                    `deployment`.`commit_sha1`               AS `commit_sha1`,
                    `deployment`.`sam_function`              AS `sam_function`,
                    `deployment`.`sam_app`                   AS `sam_app`,
                    `deployment`.`desired_replicas`          AS `desired_replicas`,
                    `deployment`.`replicas`                  AS `replicas`,
                    `deployment`.`available_replicas`        AS `available_replicas`,
                    `deployment`.`unavailable_replicas`      AS `unavailable_replicas`,
                    `deployment`.`updated_replicas`          AS `updated_replicas`,
                    `deployment`.`ready_replicas`            AS `ready_replicas`,
                    `deployment`.`message`                   AS `message`,
                    `deployment`.`ownerlabel`                AS `ownerlabel`,
                    `deployment`.`kingdom`                   AS `kingdom`,
                    `deployment`.`k8s_portal_deployment_url` AS `k8s_portal_deployment_url`,
                    `deployment`.`argus_url`                 AS `argus_url`,
                    `deployment`.`is_sam_app`                AS `is_sam_app`,
                    `deployment`.`deployment_age_in_minutes` AS `deployment_age_in_minutes`,
                    `deployment`.`consume_timestamp`         AS `consume_timestamp`,
                    `deployment`.`produce_timestamp`         AS `produce_timestamp`,
                    `deployment`.`produce_age_in_minutes`    AS `produce_age_in_minutes`,
                    `deployment`.`consume_age_in_minutes`    AS `consume_age_in_minutes`,
                    `deployment`.`payload`                   AS `payload`,
                    `deployment`.`ownerref`                  AS `owner_ref`,
                    `crd`.`overallstatus`                    AS `overall_status`,
                    `crd`.`samappmsg`                        AS `error_msg`,
                    `crd`.`bundlestatus`                     AS `bundle_status`
          FROM      (
              (
                SELECT *,
                  json_unquote(json_extract(`deploymentDetailView`.`payload`,'$.metadata.ownerReferences[0].uid')) AS `ownerref`
                FROM   `sam_kube_resource`.`deploymentDetailView`) `deployment`
              LEFT JOIN
              (
                SELECT `crd_status_view`.`appname`       AS `appname`,
                       `crd_status_view`.`namespace`     AS `namespace`,
                       `crd_status_view`.`controlestate` AS `controlestate`,
                       `crd_status_view`.`samappmsg`     AS `samappmsg`,
                       `crd_status_view`.`bundlename`    AS `bundlename`,
                       `crd_status_view`.`bundleid`      AS `bundleid`,
                       `crd_status_view`.`bundlestatus`  AS `bundlestatus`,
                       `crd_status_view`.`overallstatus` AS `overallstatus`
                FROM   `sam_kube_resource`.`crd_status_view`) `crd`
                ON       ((
                            `deployment`.`control_estate` = `crd`.`controlestate`)
                          AND       (
                            cast(`deployment`.`app_name` AS char(255) charset latin1) = `crd`.`appname`)
                          AND       (
                            `deployment`.`ownerref` = `crd`.`bundleid`)));

        GRANT ALL PRIVILEGES ON sam_kube_resource.* TO 'mani-repo-watch'@'%';
        GRANT ALL PRIVILEGES ON sam_kube_resource.* TO 'pseudo-api'@'%';
        GRANT ALL PRIVILEGES ON sam_kube_resource.* TO 'reporter'@'%';
        GRANT ALL PRIVILEGES ON sam_kube_resource.* TO 'sdpv2'@'%';
        GRANT ALL PRIVILEGES ON sam_kube_resource.* TO 'watchdog'@'%';
        GRANT ALL PRIVILEGES ON sam_kube_resource.* TO 'ssc-prd'@'%';
        GRANT ALL PRIVILEGES ON sam_kube_resource.* TO 'ssc-prod'@'%';
        GRANT ALL PRIVILEGES ON sam_kube_resource.* TO 'host-repair-agg'@'%';
        GRANT ALL PRIVILEGES ON sam_kube_resource.* TO 'sam_developer'@'%';
|||,
},
    kind: "ConfigMap",
    metadata: if configs.estate == "prd-data-flowsnake" then {
        labels: {
            app: "mysql",
                },
        name: "mysql",
        namespace: "flowsnake",
    } else {
        labels: {
            app: "mysql-inmem",
        },
        name: "mysql-inmem",
        namespace: "sam-system",
    },
    apiVersion: "v1",
} else "SKIP"
