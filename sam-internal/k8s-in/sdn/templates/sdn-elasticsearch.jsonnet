local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = (import "sdnimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sdc" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                containers: [
                    {
                        name: "sdn-elasticsearch",
                        image: sdnimages.hyperelk,
                        env: [
                                {
                                    name: "RUN",
                                    value: "elasticsearch",
                                },
                        ],
                        ports: {
                            containerPort: portconfigs.sdn.sdn_elasticsearch,
                        },
                    },
                ],
                volumeClaimTemplates: {
                    name: "sdn-dashboard-storage",
                    storageClassName: "sdn-dashboard",
                    storageSizeRequest: "500Gi",
                },
            },
            metadata: {
                labels: {
                    name: "sdn-elasticsearch",
                    apptype: "monitoring",
                },
                namespace: "sam-system",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-elasticsearch",
        },
        name: "sdn-elasticsearch",
        namespace: "sam-system",
    },
} else "SKIP"
