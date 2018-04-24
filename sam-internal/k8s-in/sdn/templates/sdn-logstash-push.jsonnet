local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = (import "sdnimages.jsonnet") + { templateFilename:: std.thisFile };

if (configs.kingdom == "prd") then {
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "sdn-logstash-push",
                        image: sdnimages.hyperelk,
                        env: [
                                {
                                    name: "RUN",
                                    value: "logstash_push",
                                },
                                {
                                    name: "config_reload_automatic",
                                    value: "true",
                                },
                                {
                                    name: "DATA_CENTER",
                                    value: configs.kingdom,
                                },
                                {
                                    name: "AJNA_ENDPOINT",
                                    value: "ajna0-broker1-0-prd.data.sfdc.net:9093",
                                },
                                {
                                    name: "TRUSTSTORE_LOCATION",
                                    value: "/etc/pki/java/cacerts_sfdc_internal.jks",
                                },
                                {
                                    name: "KEYSTORE_LOCATION",
                                    value: "/etc/logstash/certs/keystore.jks",
                                },
                                {
                                    name: "KEYSTORE_PASSWORD",
                                    value: "password",
                                },
                                {
                                    name: "TOPIC",
                                    value: "sfdc.prod.sdn__prd.ajna_local__log",
                                },
                        ],
                        volumeMounts: [
                            sdnconfigs.sdn_logstash_certs_volume_mount,
                            sdnconfigs.sdn_logstash_keystore_volume_mount,
                            {
                                mountPath: "/var/log",
                                name: "sdnlogs",
                            },
                        ],
                    },
                    {
                        name: "sdn-keytool-agent",
                        image: sdnimages.hyperelk,
                        env: [
                                {
                                    name: "RUN",
                                    value: "keytool_agent",
                                },
                                {
                                    name: "OUTPUT_FILE",
                                    value: "/etc/logstash/certs/keystore.jks",
                                },
                                {
                                    name: "REPO_DIR",
                                    value: "/etc/pki_service/root/sdn_agent",
                                },
                                {
                                    name: "CERT_PASSWORD",
                                    value: "password",
                                },
                                {
                                    name: "CONVERT_INTERVAL",
                                    # 0.5 days in seconds
                                    value: "43200",
                                },
                        ],
                        volumeMounts: [
                            sdnconfigs.sdn_logstash_keystore_volume_mount,
                            sdnconfigs.sdn_agent_cert_volume_mount,
                        ],
                    },
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
                volumes: [
                    sdnconfigs.sdn_logstash_certs_volume,
                    sdnconfigs.sdn_logstash_keystore_volume,
                    sdnconfigs.sdn_agent_cert_volume,
                    sdnconfigs.sdn_logs_volume,
                ],
            },
            metadata: {
                labels: {
                    name: "sdn-logstash-push",
                    apptype: "monitoring",
                },
                namespace: "sam-system",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sdn-logstash-push",
        },
        name: "sdn-logstash-push",
        namespace: "sam-system",
    },
} else "SKIP"
