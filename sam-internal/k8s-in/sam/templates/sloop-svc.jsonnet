local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";
local monitoredestates = (import "util_functions.jsonnet").get_estate_port_mapping(configs.kingdom);

local genport(estate, port, targetport) = {
    name: "sloop-port-" + estate,
    port: port,
    protocol: "TCP",
    targetPort: targetport,
};

local genportannotation(estate, port, targetport) = {
    port: port,
    targetport: targetport,
    nodeport: 0,
    lbtype: "",
    reencrypt: false,
    sticky: 0,
};

if samfeatureflags.sloop then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "sloop",
        namespace: "sam-system",
        labels: {
            app: "sloop",
        } + configs.ownerLabel.sam,
        annotations: {
            "slb.sfdc.net/name": "sloop-" + configs.estate,
            "slb.sfdc.net/portconfigurations": std.toString(
                [genportannotation(x.estate, x.port, x.targetport) for x in monitoredestates]
),
        },
    },
    spec: {
        ports: [genport(x.estate, x.port, x.targetport) for x in monitoredestates],
        selector: {
            app: "sloopds",
        },
    },
} else "SKIP"
