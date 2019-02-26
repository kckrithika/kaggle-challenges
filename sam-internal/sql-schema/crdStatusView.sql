alter VIEW  `crd_status_view` AS
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