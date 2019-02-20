CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `PoolMapsExpanded` AS
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

