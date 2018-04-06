local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = (import "sdnimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sam" then {
    kind: "StatefulSet",
    spec: {
        serviceName: "sdn-elasticsearch",
        volumeClaimTemplates: [
            {
                metadata: {
                   name: "sdn-dashboard",
                },
                spec: {
                   accessModes: [
                      "ReadWriteOnce",
                   ],
                   storageClassName: "sdn-dashboard-hdd-pool",
                   resources: {
                      requests: {
                         storage: "500Gi",
                      },
                   },
                },
            },
        ],
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
                        ports: [
                            {
                                containerPort: portconfigs.sdn.sdn_elasticsearch,
                            },
                        ],
                    },
                ],
                terminationGracePeriodSeconds: 30,
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
    apiVersion: "apps/v1beta1",
    metadata: {
        labels: {
            name: "sdn-elasticsearch",
        },
        name: "sdn-elasticsearch",
        namespace: "sam-system",
    },
} else "SKIP"
