local configs = import "config.jsonnet";
local slbimages = import "slbimages.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
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
            vips: slbconfigs.hsmEnabledVips,
        },
    ],
};

if slbconfigs.isSlbEstate && slbflights.proxyConfigMapEnabled then {
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
