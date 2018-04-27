local ajna_applog_auth = import "ajna_applog_auth.jsonnet";
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
}
