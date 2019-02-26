ALTER VIEW `deployment_detail_view2` AS
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
                  `deployment`.`ownerref`                  AS `ownerref`,
                  `crd`.`overallstatus`                    AS `overallstatus`,
                  `crd`.`samappmsg`                        AS `errormsg`,
                  `crd`.`bundlestatus`                     AS `bundlestatus`
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
                            `deployment`.`ownerref` = `crd`.`bundleid`))));