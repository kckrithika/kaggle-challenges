local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbreservedips = import "slb-reserved-ips.jsonnet";

if configs.estate in slbreservedips.publicReservedIps || configs.estate in slbreservedips.privateReservedIps then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "slb-reserved-ips",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.slb,
    },
    data: {
            ["slb-reserved-ips-" + configs.kingdom + ".json"]: std.manifestJsonEx(slbreservedips.publicReservedIps[configs.estate] + slbreservedips.privateReservedIps[configs.estate], " "),
    },
} else "SKIP"
