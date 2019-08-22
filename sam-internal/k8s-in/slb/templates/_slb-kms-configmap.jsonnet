local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";

local kmsconfig = {
    Url: "https://smsapi1-0-" + configs.kingdom + ".data.sfdc.net",
    CAPath: "/cert2/ca.pem",
    ClientCertPath: "/cert2/client/certificates/client.pem",
    ClientCertPrivateKeyPath: "/cert2/client/keys/client-key.pem",
    LogLevel: "90",
    LogMode: "2",
    FileName: "/tmp/kms_client.log",
    MetricConnectionType: "udp",
    MetricPort: "8125",
};

if slbconfigs.isSlbEstate && slbconfigs.hsmNginxEnabledEstate then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "slb-kms-configuration",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.slb,
    },
    data: {
        [configs.kingdom + ".json"]: std.manifestJsonEx(kmsconfig, " "),
    },
} else "SKIP"
