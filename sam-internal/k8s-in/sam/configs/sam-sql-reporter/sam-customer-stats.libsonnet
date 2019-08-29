{
      name: "ProductionStatistics",
      note: "This shows statistics for SAM in Production",
      multisql: [
        {
          name: "ProductionDcsAndHosts",
          sql: "select  kingdom, count(name) as nodeCount
          from nodeDetailView
          group by kingdom
",
        },
        {
          name: "NamespacesAndDeploymentCountInProduction",
          sql: "select namespace, count(name) as payloadcount
            from deploymentDetailView
            where (
              namespace not rlike 'csc-sam' and
              namespace not rlike 'sam-watchdog' and
              namespace not rlike 'sam-system' and
              namespace not rlike 'legostore' and
              namespace not rlike 'ceph' and
              namespace not rlike 'slb' and 
              namespace not rlike 'user-' and
              control_estate not rlike 'prd' and
              control_estate not rlike 'xrd')
            group by namespace order by namespace
          ",
      },
    ],
  }
