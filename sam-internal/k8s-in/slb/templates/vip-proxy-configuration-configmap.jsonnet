local configs = import "config.jsonnet";
local slbimages = import "slbimages.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";

local vipProxyConfigs = {
    vipproxyconfigs: [
        {
            proxyname: slbconfigs.hsmNginxProxyName,
            urls: [
               "hsm-nginx-canary.slb.sfdc.net",
            ],
        },
    ],
};

if slbimages.phaseNum <= 1 then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "slb-vip-proxy-configuration",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.slb,
    },
    data: {
        "vipproxyconfiguration.json": std.manifestJsonEx(vipProxyConfigs, " "),
    },
} else "SKIP"
