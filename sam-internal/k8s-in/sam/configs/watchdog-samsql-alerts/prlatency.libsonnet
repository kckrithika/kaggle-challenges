{
    name: "PRLatency",
      instructions: "Following PRs have failed to get deployed within 45 minutes of getting authorized.",
      alertThreshold: "10m",
      alertFrequency: "336h",
      watchdogFrequency: "10m",
      alertProfile: "sam",
      alertAction: "businesshours_pagerduty",
      sql: "SELECT * FROM(
      SELECT
        prs.pr_url,
        prs.merged_time,
        crds.PoolName,
        crds.ControlEstate,
        TIMESTAMPDIFF(MINUTE,prs.merged_time, STR_TO_DATE(JSON_UNQUOTE(payload -> '$.status.endTime'),'%Y-%m-%dT%H:%i:%s' )) latency
      FROM PullRequests prs LEFT  JOIN
        (   
        SELECT *
        FROM
        crd_history
        WHERE ApiKind = 'Bundle') crds ON crds.PRNum = prs.pr_num
        WHERE  prs.merged_time > now() - INTERVAL 24 hour
        ORDER BY prs.pr_num
        ) prLatency
      WHERE latency > 45",
}

