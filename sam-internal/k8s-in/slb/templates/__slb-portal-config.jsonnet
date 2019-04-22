local configs = import "config.jsonnet";
local slbflights = import "slbflights.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";

local arr = [
    ({
        name: kingdomName,
        href: "http://slb-portal-%s.%s.%s.slb.sfdc.net" % [kingdomName, configs.estate, configs.kingdom],
    })
for kingdomName in slbconfigs.prodKingdoms
];

local perKingdomConfig = {
    links: arr + [
    {
        name: "prd-sam",
        href: "http://slb-portal-service.sam-system.prd-sdc.prd.slb.sfdc.net:9112/",
    },
    {
        name: "prd-samtwo",
        href: "http://slb-portal-service.sam-system.prd-samtwo.prd.slb.sfdc.net:9112/",
    },
],
};

if slbconfigs.isSlbEstate && configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "slb-portal-links",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.slb,
    },
    data: {
        "slbportallinks.json": std.manifestJsonEx(perKingdomConfig, " "),
    },
} else
    "SKIP"
