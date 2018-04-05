local configs = import "config.jsonnet";

if configs.kingdom == "prd" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "k8sproxy",
        namespace: "sam-system",
    },
    data: {
        "haproxy-maddog.cfg": (if configs.estate == "prd-sam" then
                                   std.format(std.toString(importstr "configs/haproxy-maddog-acl.cfg"), configs.chainFile)
                               else if configs.estate == "prd-samtest" then
                               std.format(std.toString(importstr "configs/haproxy-maddog-apiproxy.cfg"), configs.chainFile)
                               else
                               std.format(std.toString(importstr "configs/haproxy-maddog.cfg"), configs.chainFile)),
    },
} else "SKIP"
