{
      name: "PRFailedToProduceManifestZip",
      instructions: "Following PRs have failed to produce corresponding manifest.zip file after 30 minutes of getting  merged.",
      alertThreshold: "10m",
      alertFrequency: "336h",
      watchdogFrequency: "10m",
      alertProfile: "sam",
      alertAction: "pagerduty",
      sql: "SELECT
                 *
                FROM
                (SELECT
                  p.pr_num,
                  t.manifest_zip_time,
                  p.merged_time,
                  TIMESTAMPDIFF(MINUTE, merged_time, CASE WHEN t.manifest_zip_time IS NULL THEN now() ELSE t.manifest_zip_time END) latency
                FROM PullRequests p
                LEFT OUTER JOIN TNRPManifestData t
                ON p.git_hash = t.git_hash

                WHERE p.state ='merged'   AND p.`merged_time` > NOW() - INTERVAL 10 DAY AND manifest_zip_time IS NULL order by p.merged_time desc)
                 manifestZip
                WHERE manifestZip.latency > 30",
    }

