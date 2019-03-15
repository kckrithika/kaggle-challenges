local configs = import "config.jsonnet";
local slbimages = import "slbimages.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local tcpdumpCommandSet = {
    tcpdumpcommands: [
        {
            command: "-i any",
            duration: "1m",
            packetcapture: false,
        },
    ],
};

if slbconfigs.isSlbEstate && slbflights.slbTCPdumpEnabled then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: slbconfigs.hsmNginxProxyName,
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.slb,
    },
    data: {
        "tcpdumpipvscommand.json": std.manifestJsonEx(tcpdumpCommandSet, " "),
    },
} else "SKIP"
