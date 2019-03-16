local configs = import "config.jsonnet";
local slbimages = import "slbimages.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";

{
    slbtcpdumpService(command, duration, packetcapture, proxyName):: (
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
                name: proxyName,
                namespace: "sam-system",
                labels: {} + configs.ownerLabel.slb,
            },
            data: {
                "tcpdumpcommand.json": std.manifestJsonEx(slbAnnotations, " "),
            },
        }
    ),
}
