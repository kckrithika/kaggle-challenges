{
        name: "SqlKubeApiNode",
        instructions: "The following minion pools have kubeApi nodes down requiring immediate attention. Debug Instructions: https://git.soma.salesforce.com/sam/sam/wiki/Repair-Failed-SAM-Host",
        alertThreshold: "20m",
        alertFrequency: "24h",
        watchdogFrequency: "5m",
        alertProfile: "sam",
        alertAction: "pagerduty",
        sql: "SELECT Name,
                ControlEstate,
                MinionPool,
                Ready
              FROM nodeDetailView
              WHERE Name LIKE '%kubeapi%' AND Ready !='True' AND
                 ControlEstate NOT LIKE '%sdc%' AND
                 ControlEstate NOT LIKE '%storage%' AND
                 ControlEstate NOT LIKE '%samdev%' AND
                 ControlEstate NOT LIKE '%samtest%'",
        }

