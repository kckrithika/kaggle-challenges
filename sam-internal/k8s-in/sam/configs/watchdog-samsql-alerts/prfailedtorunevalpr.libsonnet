{
      name: "PRFailedToRunEvalPR",
      instructions: "Following PRs haven't run evaluatePR more than 30 mins after getting authorized.",
      alertThreshold: "10m",
      alertFrequency: "336h",
      watchdogFrequency: "10m",
      alertProfile: "sam",
      alertAction: "businesshours_pagerduty",
      sql: "SELECT 
         *   
        FROM
        (SELECT 
          pr_num,
          created_time,
          evaluate_pr_status,
          authorized_by,
          most_recent_authorized_time,
          TIMESTAMPDIFF(MINUTE,  most_recent_authorized_time, now()) latency
        FROM PullRequests
        WHERE created_time IS NOT NULL AND created_time  > NOW() - Interval 10 day AND authorized_by IS NOT NULL AND authorized_by !='' AND (`evaluate_pr_status` IS NULL OR evaluate_pr_status = 'unknown') AND most_recent_authorized_time IS NOT NULL
            AND state ='open'
        ) authedButUnkwn
        WHERE authedButUnkwn.latency > 30",
    }

