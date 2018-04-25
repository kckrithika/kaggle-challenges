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
                         storage: "1750Gi",
                      },
                   },
                },
            },
        ],
        replicas: 1,
        template: {
            spec: {
                securityContext: {
                    fsGroup: 7447,
                },
                hostNetwork: true,
                containers: [
                    {
                        name: "sdn-elasticsearch",
                        image: sdnimages.hyperelk,
                        env: [
                                {
                                    name: "RUN",
                                    value: "elasticsearch",
                                },
                                {
                                    name: "http_port",
                                    value: portconfigs.sdn.sdn_elasticsearch,
                                },
                        ],
                        livenessProbe: {
                            tcpSocket: {
                               port: portconfigs.sdn.sdn_elasticsearch,
                            },
                            initialDelaySeconds: 15,
                            periodSeconds: 10,
                            failureThreshold: 100,
                        },
                        ports: [
                            {
                                containerPort: portconfigs.sdn.sdn_elasticsearch,
                            },
                        ],
                        volumeMounts: [
                            {
                                name: "sdn-dashboard",
                                mountPath: "/usr/share/elasticsearch/data",
                            },
                        ],
                    },
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
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
