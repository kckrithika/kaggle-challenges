local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";


if samfeatureflags.k8sproxy then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "k8sproxy",
        namespace: "sam-system",
    },
    data: {
        "haproxy.cfg": std.format(std.toString(importstr "configs/haproxy-maddog-acl.cfg"), configs.chainFile),
    },
} else "SKIP"
