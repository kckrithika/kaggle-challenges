alter VIEW `PullRequestLatencyView` AS
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
    `p`.`merged_time` DESC
