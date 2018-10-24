local timeMillisecond = 1000000;
local timeSecond = timeMillisecond * 1000;
local timeMinute = 60 * timeSecond;
local timeHour = 60 * timeMinute;

{
    enabled: true,
    requestsToMake: 105,
    requestsToSkip: 5,
    port: "3334",
    requestDataSizes: "1B",
    requestDataSizeMax: "1B",

    reportsEndpointEnabled: true,
    reportsPercentiles: "50,75,90,95,99",
    numWorkers: 5,
    selectorLabelName: "sam-network-reporter",
    testMode: false,

    shouldBatchMetrics: true,

    enablehttp: false,
    enabletcp: true,
    tcpPort: "3333",

    requestDelay: 10 * timeMillisecond,
    delay: 5 * timeMinute,
    refreshNodesMaxDelay: 24 * timeHour,
    refreshNodesMinDelay: 23 * timeHour,
    timeout: 30 * timeSecond,
    backoffMin: 5 * timeSecond,
    backoffJitterMax: 1 * timeHour,
    metricsHttpTimeout: timeSecond * 5,
    metricsBatchTimeout: timeMinute,
}
