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
                            sdnconfigs.sdn_logstash_conf_volume_mount,
                            sdnconfigs.sdn_logstash_certs_volume_mount,
                        ],
                    },
                    {
                        name: "sdn-argus-auth-agent",
                        image: sdnimages.hypersdn,
                        volumeMounts: [
                            sdnconfigs.sdn_logstash_conf_volume_mount,
                            configs.maddog_cert_volume_mount,
                            configs.cert_volume_mount,
                        ],
                        command: [
                            "/sdn/sdn-argus-auth-agent",
                            "--svcSecretServiceUsername=svc_sdn",
                            "--certfile=" + configs.certFile,
                            "--keyfile=" + configs.keyFile,
                            "--cafile=" + configs.caFile,
                            "--topicsPattern=sfdc.prod.rsyslog__prd.ajna_local__logs.sam",
                            "--confFile=/etc/logstash/conf.d/logstash.conf",
                            "--truststoreFile=/etc/logstash/certs/truststore.jks",
                            "--elasticsearchUrl=" + sdnconfigs.sdn_elasticsearch_cluster_ip + ":" + portconfigs.sdn.sdn_elasticsearch,
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
                                    value: "/etc/logstash/certs/truststore.jks",
                                },
                                {
                                    name: "CERT_PASSWORD",
                                    value: "password",
                                },
                                {
                                    name: "CERT_DIR",
                                    value: "/etc/pki_service/ca/",
                                },
                                {
                                    name: "CONVERT_INTERVAL",
                                    # 1 day in seconds
                                    value: "86400",
                                },
                        ],
                        volumeMounts: [
                            sdnconfigs.sdn_logstash_certs_volume_mount,
                            configs.maddog_cert_volume_mount,
                        ],
                    },
                ],
                volumes: [
                    sdnconfigs.sdn_logstash_conf_volume,
                    sdnconfigs.sdn_logstash_certs_volume,
                    configs.maddog_cert_volume,
                    configs.cert_volume,
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
