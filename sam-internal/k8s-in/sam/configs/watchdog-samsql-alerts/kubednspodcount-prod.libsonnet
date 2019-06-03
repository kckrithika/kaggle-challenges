{
      name: "KubednsPodCountProd",
      alertThreshold: "5m",
      alertFrequency: "336h",
      watchdogFrequency: "1m",
      alertProfile: "sam",
      alertAction: "email",
      sql: "SELECT
              controlEstate,
              Running,
              NotRunning
            FROM
            (
            SELECT
              controlEstate,
              SUM(Running) as Running,
              SUM(NotRunning) as NotRunning
            FROM
            (
            SELECT
              controlEstate,
              (CASE WHEN Phase = 'Running' then 1 else 0 end) as Running,
              (CASE WHEN Phase <> 'Running' then 1 else 0 end) as NotRunning
            FROM podDetailView
            WHERE namespace = 'kube-system' AND name LIKE 'kube-dns-%' AND (upper(Kingdom) NOT IN ('PRD', 'XRD', 'LO2', 'LO3'))
            ) as ss
            GROUP BY controlEstate
            ORDER BY NotRunning desc
            ) as ss1
            WHERE
             Running < NotRunning",
    }
