{
      name: "SqlCustomerAppsWithImagePullErrorsProd",
      alertThreshold: "5m",
      alertFrequency: "24h",
      watchdogFrequency: "1m",
      alertProfile: "sam",
      alertAction: "email",
      sql: "select * from podDetailView where 
        JSON_SEARCH(
          Payload->>'$.status.containerStatuses[*].state.waiting.reason', 'one', 'ImagePullBackOff')
            is not null 
          AND Kingdom != 'prd' 
          AND Kingdom != 'xrd' 
          AND IsSamApp = 1;",
    }
