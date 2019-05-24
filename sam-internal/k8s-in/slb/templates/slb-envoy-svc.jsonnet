local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";
local slbflights = import "slbflights.jsonnet";
local commonutils = import "util_functions.jsonnet";

local podName = slbconfigs.envoyProxyName;
local serviceName = podName + "-service";
local vipName = "service-mesh-ingress";

// prd is special since we have several estates -- disambiguate using the location.
// For non-prd kingdoms, disambiguate using the kingdom.
local cnameLocation =
    if configs.kingdom == "prd" then
        commonutils.string_replace(configs.estate, "_", "-")
    else
        configs.kingdom;

local cnames = [
    {
        cname: "mesh-" + cnameLocation + ".slb.sfdc.net",
    },
];

local portConfig = [
    slbportconfiguration.newPortConfiguration(
        port=7013,
        // lbType="dsr" -- if configuring via pipelines doesn't work.
        lbType="http",
        name="slb-envoy-ingress-port-http1",
    ),
    slbportconfiguration.newPortConfiguration(
        port=5442,
        // lbType="dsr" -- if configuring via pipelines doesn't work.
        lbType="http",
        name="slb-envoy-ingress-port-http1-tls",
    ),
    slbportconfiguration.newPortConfiguration(
        port=7011,
        // lbType="dsr" -- if configuring via pipelines doesn't work.
        lbType="http",
        name="slb-envoy-ingress-port-http2",
    ),
    slbportconfiguration.newPortConfiguration(
        port=5443,
        // lbType="dsr" -- if configuring via pipelines doesn't work.
        lbType="http",
        name="slb-envoy-ingress-port-http2-tls",
    ),
];

if slbconfigs.isSlbEstate && (slbflights.envoyProxyEnabled) then
    slbbaseservice.slbCanaryBaseService(podName, portConfig, serviceName, vipName, cnames) {
    spec+: {
        // Override the selector -- I don't want this VIP to select any pods for now.
        selector: {
            name: slbconfigs.envoyProxyName + "-zyzzyx",
        },
    },
} else "SKIP"
