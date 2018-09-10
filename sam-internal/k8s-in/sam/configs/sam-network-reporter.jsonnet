local timeMillisecond = 1000000;
local timeSecond = timeMillisecond * 1000;
local timeMinute = 60 * timeSecond;
local timeHour = 60 * timeMinute;

{
    Enabled: true,
    RequestsToMake: 205,
    RequestsToSkip: 5,
    Port: "3333",
    RequestDataSizes: "32B,100B,500B,2KB,10KB,100KB,1MB",
    RequestDataSizeMax: "1MB",

    ReportsEndpointEnabled: true,
    ReportsPercentiles: "50,75,90,95,99",
    NumWorkers: 5,
    SelectorLabelName: "sam-network-reporter",
    TestMode: false,

    ShouldBatchMetrics: true,

        EnableHttp: false,
        EnableTcp: true,
        TcpPort: "3333",

    RequestDelay: 10 * timeMillisecond,
    Delay: 60 * timeSecond,
    RefreshNodesMaxDelay: 5 * timeMinute,
    RefreshNodesMinDelay: 5 * timeSecond,
    Timeout: 30 * timeSecond,
    BackoffMin: 5 * timeSecond,
    BackoffJitterMax: 1 * timeHour,
    MetricsHTTPTimeout: timeSecond * 5,
    MetricsBatchTimeout: timeMinute,
}
