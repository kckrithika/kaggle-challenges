{
    enabled: true,
    requestsToMake: 105,
    requestsToSkip: 5,
    port: "3333",
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
    tcpPort: "53353",

    requestDelay: "10ms",
    delay: "5m",
    refreshNodesMaxDelay: "24h",
    refreshNodesMinDelay: "1h",
    timeout: "30s",
    backoffMin: "5s",
    backoffJitterMax: "1h",
    metricsHttpTimeout: "5s",
    metricsBatchTimeout: "1m",

    namespace: "sam-system",
}
