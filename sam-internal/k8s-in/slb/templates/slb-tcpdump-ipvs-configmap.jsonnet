local configs = import "config.jsonnet";
local slbimages = import "slbimages.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local tcpdumpCommandSet = {
    tcpdumpcommands: [
        {
            command: "-i any",
            duration: "5m",
            packetcapture: true,
        },
    ],
};

if slbconfigs.isSlbEstate && slbflights.slbTCPdumpEnabled then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "slb-tcpdump-ipvs",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.slb,
    },
    data: {
        "tcpdumpipvscommand.json": std.manifestJsonEx(tcpdumpCommandSet, " "),
    },
} else "SKIP"
