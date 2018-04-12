local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local sdnconfigs = import "sdnconfig.jsonnet";
local sdnimages = (import "sdnimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
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
                            "--svcUsername=svc_sdn",
                            "--certfile=" + configs.certFile,
                            "--keyfile=" + configs.keyFile,
                            "--cafile=" + configs.caFile,
                            "--topicsPattern=sfdc.prod.rsyslog__prd.ajna_local__logs.sam",
                            "--confFile=/etc/logstash/conf.d/logstash.conf",
                            "--truststoreFile=/etc/pki/java/cacerts_sfdc_internal.jks",
                            "--elasticsearchUrl=" + sdnconfigs.sdn_elasticsearch_cluster_ip + ":" + portconfigs.sdn.sdn_elasticsearch,
                            "--userName=platform",
                            "--ajnaEndpoint=ajna0-broker1-0-prd.data.sfdc.net:9093",
                        ],
                    },
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
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
