local configs = import "config.jsonnet";
local slbimages = import "slbimages.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";

{
    slbtcpdumpService(command, duration, packetcapture, proxyName):: (
        local proxyNameInternal = if slbflights.tcpdumpNamingRevamp then
            (proxyName + "-tcpdump") else
            proxyName;
        local slbAnnotations = {
            tcpdumpcommands: [
                {
                    command: command,
                    duration: duration,
                    packetcapture: packetcapture,
                },
            ],
        };

        {
            kind: "ConfigMap",
            apiVersion: "v1",
            metadata: {
                name: proxyNameInternal,
                namespace: "sam-system",
                labels: {} + configs.ownerLabel.slb,
            },
            data: {
                "tcpdumpcommand.json": std.manifestJsonEx(slbAnnotations, " "),
            },
        }
    ),
}
