local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = (import "sdnimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-sdc" then configs.daemonSetBase("sdn") {
    spec+: {
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
                                    value: "ajna0-broker1-0-" + configs.kingdom + ".data.sfdc.net:9093",
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
                                    value: "sfdc.prod.rsyslog__" + configs.kingdom + ".ajna_local__logs.sdn",
                                },
                        ],
                        volumeMounts: [
                            sdnconfigs.sdn_logstash_certs_volume_mount,
                            sdnconfigs.sdn_logstash_keystore_volume_mount,
                            {
                                mountPath: "/var/logs/sdn",
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
                } + (if configs.kingdom != "prd" &&
                        configs.kingdom != "xrd" then
                        configs.ownerLabel.sdn else {}),
                namespace: "sam-system",
            },
        },
        [if sdnimages.phase == "1" || sdnimages.phase == "2" then "updateStrategy"]: {
            type: "RollingUpdate",
            rollingUpdate: {
            maxUnavailable: "25%",
            },
        },
    },
    metadata: {
        labels: {
            name: "sdn-logstash-push",
        } + configs.ownerLabel.sdn,
        name: "sdn-logstash-push",
        namespace: "sam-system",
    },
} else "SKIP"
