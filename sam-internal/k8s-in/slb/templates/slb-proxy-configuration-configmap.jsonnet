local configs = import "config.jsonnet";
local slbimages = import "slbimages.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";

local proxyConfigs = {
    proxyconfigs: [
        {
            name: slbconfigs.nginxProxyName,
            healthport: 12080,
            healthpath: "/",
        },
        {
            name: slbconfigs.hsmNginxProxyName,
            healthport: 12080,
            healthpath: "/",
        },
    ],
};

local proxyVipMapping = {
    proxyvipmappings: [
        {
            proxyname: slbconfigs.hsmNginxProxyName,
            vips: [
               "hsm-nginx-canary.slb.sfdc.net",
            ],
        },
    ],
};

if slbimages.phaseNum <= 1 then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "slb-proxy-configuration",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.slb,
    },
    data: {
        "proxyconfiguration.json": std.manifestJsonEx(proxyConfigs, " "),
        "proxyvipmapping.json": std.manifestJsonEx(proxyVipMapping, " "),
    },
} else "SKIP"
