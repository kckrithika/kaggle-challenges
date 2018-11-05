{
      name: "SqlPRAuthroizationLinkPostTimeLatency",
      instructions: "Following PRs don't have authorization link after 5 minutes of getting created.",
      alertThreshold: "10m",
      alertFrequency: "24h",
      watchdogFrequency: "10m",
      alertProfile: "sam",
      alertAction: "pagerDuty",
      sql: "SELECT
          * 
        FROM (SELECT 
            pr_num,
            TIMESTAMPDIFF(MINUTE, created_time, CASE WHEN first_approval_link_posted_time IS NULL THEN now() ELSE first_approval_link_posted_time END) latency,
            first_approval_link_posted_time,
            created_time
        FROM PullRequests 
        WHERE created_time IS NOT NULL AND created_time > NOW() - Interval 10 day AND state ='open') noApprovalLinkInMin
        WHERE noApprovalLinkInMin.latency > 5
        ORDER BY latency desc",
    }

