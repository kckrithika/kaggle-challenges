{
      name: "CustomerAppsWithImagePullErrorsProd",
      alertThreshold: "5m",
      alertFrequency: "336h",
      watchdogFrequency: "1m",
      alertProfile: "sam",
      alertAction: "businesshours_pagerduty",
      sql: "select 
  controlEstate,
  namespace,
  name,
  nodename,
  phase,
  Payload->>'$.status.containerStatuses[*].state.waiting.reason' as reason,
  Payload->>'$.status.containerStatuses[*].state.waiting.message' as message
from podDetailView where 
  JSON_SEARCH(Payload->>'$.status.containerStatuses[*].state.waiting.reason', 'one', 'ImagePullBackOff') is not null 
  AND Kingdom != 'prd' 
  AND Kingdom != 'xrd' 
  AND IsSamApp = 1;",
    }
