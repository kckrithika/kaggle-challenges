{
            name: "SqlSamControlDeployer",
            instructions: "The following SAM control stack components dont have a healhty autodeployer pod",
            alertThreshold: "20m",
            alertFrequency: "24h",
            watchdogFrequency: "5m",
            alertProfile: "sam",
            alertAction: "businesshours_pagerduty",
            sql: "select
                      ControlEstate,
                      name,
                      NodeName
                  from podDetailView
                  where
                  Phase <> 'Running' and
                  Namespace = 'sam-system' and name like 'samcontrol-deployer%' ",
    }

