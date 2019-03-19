local configs = import "config.jsonnet";
local slbimages = import "slbimages.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local tcpdumpbaseservice = import "slb-tcpdump-base-configmap.libsonnet";

local Command = "-i eth0";
local Duration = "1m";
local Packetcapture = false;

if slbconfigs.isSlbEstate && slbflights.slbTCPdumpEnabled then
    tcpdumpbaseservice.slbtcpdumpService(Command, Duration, Packetcapture, slbconfigs.hsmNginxProxyName) {
} else "SKIP"
