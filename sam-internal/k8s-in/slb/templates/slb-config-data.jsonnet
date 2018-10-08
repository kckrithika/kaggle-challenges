local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbflights = import "slbflights.jsonnet";

if slbconfigs.isSlbEstate && configs.estate != "prd-sam_storage" then configs.daemonSetBase("slb") {
    metadata: {
        labels: {
            name: "slb-config-data",
        } + configs.ownerLabel.slb,
        name: "slb-config-data",
        namespace: "sam-system",
    },
    spec+: {
        template: {
            metadata: {
                labels: {
                    name: "slb-config-data",
                    apptype: "control",
                    daemonset: "true",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec:
                (if slbconfigs.slbInProdKingdom then { hostNetwork: true }
                 else {})
                +
                {
                    volumes: configs.filter_empty([
                        slbconfigs.slb_volume,
                    ]),
                    containers: [
                        {
                            name: "slb-config-data",
                            image: slbimages.hypersdn,
                            [if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then "resources"]: configs.ipAddressResource,
                            command: [
                                "/sdn/slb-config-data",
                                "--port=" + portconfigs.slb.slbConfigDataPort,
                            ],
                            volumeMounts: configs.filter_empty([
                                slbconfigs.slb_volume_mount,
                            ]),
                        }
                        + (
                            if configs.estate == "prd-sdc" then {
                                livenessProbe: {
                                    httpGet: {
                                        path: "/",
                                        port: portconfigs.slb.slbConfigDataPort,
                                    },
                                    initialDelaySeconds: 5,
                                    periodSeconds: 3,
                                },
                            }
                            else {}
                        ),
                    ],
                } + slbflights.getDnsPolicy(),
        },
        updateStrategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: "20%",
            },
        },
        minReadySeconds: 30,
    },
} else "SKIP"
