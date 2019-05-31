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
    ] + (if slbflights.envoyProxyEnabled then [
        {
            name: slbconfigs.envoyProxyName,
            healthport: 12080,
            healthpath: "/",
        },
    ] else [])
    + (if slbflights.deploySLBEnvoyConfig then [
        {
            name: slbconfigs.envoyProxyConfigDeploymentName,
            healthport: 8080,
            healthpath: "/liveness-probe",
        },
    ] else []),
};

local proxyVipMapping = {
    proxyvipmappings: [
        {
            proxyname: slbconfigs.hsmNginxProxyName,
            vips: slbconfigs.hsmEnabledVips,
        },

    ] + (if slbflights.envoyProxyEnabled then [
        {
            proxyname: slbconfigs.envoyProxyName,
            vips: slbconfigs.envoyEnabledVips,
        },
    ] else [])
    + (if slbflights.deploySLBEnvoyConfig then [
        {
            proxyname: slbconfigs.envoyProxyConfigDeploymentName,
            vips: slbconfigs.envoyProxyEnabledVips,
        },
    ] else []),
};

if slbconfigs.isSlbEstate then {
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
