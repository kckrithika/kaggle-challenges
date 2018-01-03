local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "prd-sam_storage" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-portal",
        },
        name: "slb-portal",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-portal",
                },
                namespace: "sam-system",
            },
            spec: {
                volumes: configs.filter_empty([
                    slbconfigs.slb_volume,
                ]),
                containers: [
                    {
                       name: "slb-portal",
                       image: slbimages.hypersdn,
                       command: [
                           "/sdn/slb-portal",
                           "--configDir=" + slbconfigs.configDir,
                           "--templatePath=" + slbconfigs.slbPortalTemplatePath,
                           "--port=" + portconfigs.slb.slbPortalServicePort,
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
                                    port: portconfigs.slb.slbPortalServicePort,
                                },
                                initialDelaySeconds: 30,
                                periodSeconds: 3,
                            },
                        }
                        else {}
                       ),
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
            },
        },
    },
} else "SKIP"
