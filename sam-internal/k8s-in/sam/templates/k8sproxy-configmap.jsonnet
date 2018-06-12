local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

local haproxy_maddog_config =
    if configs.estate == "prd-samdev" then
        std.format(std.toString(importstr "configs/haproxy-maddog-api-acl.cfg"), configs.chainFile)
    else
        std.format(std.toString(importstr "configs/haproxy-maddog-acl.cfg"), configs.chainFile);

if samfeatureflags.k8sproxy then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "k8sproxy",
        namespace: "sam-system",
    },
    data: {
        "haproxy.cfg": haproxy_maddog_config,
    },
} else "SKIP"
