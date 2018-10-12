local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";

local deploymentName = "slb-echo-server";
local serviceName = "slb-echo-svc";
local vipName = serviceName;

local echoSvcPortConfig = [
    slbportconfiguration.newPortConfiguration(
        port=portconfigs.slb.slbEchoServicePort,
        lbType="tcp",
        name="slb-echo-port",
        nodePort=portconfigs.slb.slbEchoServiceNodePort,
    ),
];

if configs.estate == "prd-sdc" then
    slbbaseservice.slbCanaryBaseService(deploymentName, echoSvcPortConfig, serviceName, vipName) {

    // TODO: this is vestigial and should be removed.
    metadata+: {
        labels+: {
            "slb.sfdc.net/type": "tcp",
        },
    },
} else "SKIP"
