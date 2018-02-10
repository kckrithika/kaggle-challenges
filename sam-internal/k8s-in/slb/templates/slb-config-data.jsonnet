local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        labels: {
            name: "slb-config-data",
        },
        name: "slb-config-data",
        namespace: "sam-system",
    },
    spec: {
        template: {
            metadata: {
                labels: {
                    name: "slb-config-data",
                    apptype: "control",
                    daemonset: "true",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                 ]),
                containers: [
                        {
                            name: "slb-config-data",
                            image: slbimages.hypersdn,
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
             },
        },
    },
} else "SKIP"
