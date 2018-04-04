local configs = import "config.jsonnet";
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
                        name: "sdn-logstash",
                        image: sdnimages.hyperelk,
                        env: [
                                {
                                    name: "RUN",
                                    value: "logstash",
                                },
                                {
                                    name: "config_reload_automatic",
                                    value: "true",
                                },
                        ],
                        volumeMounts: [
                            sdnconfigs.sdn_logstash_volume_mount,
                        ],
                    },
                ],
                volumes: [
                    sdnconfigs.sdn_logstash_volume,
                ],
            },
            metadata: {
                labels: {
                    name: "sdn-logstash",
                    apptype: "monitoring",
                },
                namespace: "sam-system",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-logstash",
        },
        name: "sdn-logstash",
        namespace: "sam-system",
    },
} else "SKIP"
