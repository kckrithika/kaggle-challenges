local ajna_applog_auth = import "ajna_applog_auth.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_v1_enabled then
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "ajna-applog-logrecordtype-whitelist",
        namespace: "flowsnake",
    },
    data: {
        data: std.toString(ajna_applog_auth.ajna_applog_logrecordtype_whitelist),
    },
} else "SKIP"
