local configs = import "config.jsonnet";
local slbimages = import "slbimages.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local tcpdumpbaseservice = import "slb-tcpdump-base-configmap.libsonnet";

local command = "-i tunl0";
local duration = "1m";
local packetCapture = false;

if slbconfigs.isSlbEstate && slbflights.deploySLBEnvoyConfig then
    tcpdumpbaseservice.slbtcpdumpService(command, duration, packetCapture, slbconfigs.envoyProxyConfigDeploymentName)
else "SKIP"
