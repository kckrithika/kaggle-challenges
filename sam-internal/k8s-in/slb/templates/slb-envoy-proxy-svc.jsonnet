local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";
local slbflights = import "slbflights.jsonnet";

local podName = slbconfigs.envoyProxyName;
local serviceName = podName + "-service";
local vipName = "service-mesh-ingress";

local portConfig = [
    slbportconfiguration.newPortConfiguration(
        port=9115,
        // lbType="dsr" -- if configuring via pipelines doesn't work.
        lbType="http",
        name="slb-envoy-ingress-port",
    ),
];

if slbconfigs.isSlbEstate && slbflights.envoyProxyEnabled then
    slbbaseservice.slbCanaryBaseService(podName, portConfig, serviceName, vipName) {
    spec+: {
        // Override the selector -- I don't want this VIP to select any pods for now.
        selector: {
            name: slbconfigs.envoyProxyName + "-zyzzyx",
        },
    },
} else "SKIP"
