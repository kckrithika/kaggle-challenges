alter VIEW `PullRequestByTeam` AS
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

