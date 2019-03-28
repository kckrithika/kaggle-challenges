local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";
local images = (import "collection-agent-images.libsonnet") + { templateFilename:: std.thisFile };

{
    baseEnv: [
        {
            name: "BROKER_VIP",
            valueFrom: {
                configMapKeyRef: {
                    name: "kafka-cm",
                    key: "broker_vip",
                },
            },
        },
        {
            name: "POD_NAME",
            valueFrom: {
                fieldRef: {
                    fieldPath: "metadata.name",
                },
            },
        },
        {
            name: "POD_NAMESPACE",
            valueFrom: {
                fieldRef: {
                    fieldPath: "metadata.namespace",
                },
            },
        },
    ],

    ## generated rsyslog config files for rsyslog daemonset
    rsyslog_config_volume():: [
        {
            name: "rsyslog-config",
            emptyDir: {},
        },
    ],
    rsyslog_config_volume_mounts():: [
        {
            mountPath: "/etc/rsyslog.d",
            name: "rsyslog-config",
        },
    ],

    ## generated cadvisor yaml file and rsyslog config file for cadvisor-rsyslog daemonset
    cadvisor_yaml_volume():: [
        {
            name: "cadvisor-yaml",
            emptyDir: {},
        },
        {
            name: "rsyslog-config",
            emptyDir: {},
        },
    ],
    cadvisor_yaml_volume_mounts():: [
        {
            mountPath: "/etc/cadvisor",
            name: "cadvisor-yaml",
        },
        {
            mountPath: "/etc/rsyslog.d",
            name: "rsyslog-config",
        },
    ],

    ## rsyslog daemonset config-gen templates
    rsyslog_config_gen_tpl_volume():: [
        {
            name: "rsyslog-config-tpl",
            configMap: {
                name: "rsyslog-configmap",
            },
        },
    ],
    rsyslog_config_gen_tpl_volume_mounts():: [
        {
            mountPath: "/templates/rsyslog",
            name: "rsyslog-config-tpl",
        },
    ],

    ## cadvisor-rsyslog config-gen templates
    cadvisor_config_gen_tpl_volume_mounts():: [
        {
            mountPath: "/templates/cadvisor",
            name: "cadvisor-config-tpl",
        },
    ],
    cadvisor_config_gen_tpl_volume():: [
        {
            name: "cadvisor-config-tpl",
            configMap: {
                name: "cadvisor-configmap",
            },
        },
    ],

    ## rsyslog daemonset specific volumes
    rsyslog_volume():: [
        {
            name: "varlog",
            hostPath: {
                path: "/var/log",
            },
        },
        {
            name: "varlibdockercontainers",
            hostPath: {
                path: "/var/lib/docker/containers",
            },
        },
        {
            name: "logs-vol",
            hostPath: {
                path: "/mnt/disks/ssd0/data/logs",
            },
        },
        {
            name: "rsyslog-workdir",
            hostPath: {
                path: "/var/spool/rsyslog",
            },
        },
        {
            name: "rsyslog-imjournal",
            hostPath: {
                path: "/var/log/journal",
            },
        },
    ],
    rsyslog_volume_mounts():: [

        {
            mountPath: "/var/log",
            name: "varlog",
        },
        {
            mountPath: "/var/lib/docker/containers",
            name: "varlibdockercontainers",
        },
        {
            name: "logs-vol",
            mountPath: "/home/sfdc/logs",
        },
        {
            mountPath: "/var/spool/rsyslog",
            name: "rsyslog-workdir",
        },
        {
            mountPath: "/run/log/journal",
            name: "rsyslog-imjournal",
        },

    ],

    ## sfdc-scraper specific volumes
    sfdc_scraper_volume():: [
        {
            name: "var-run",
            hostPath: {
                path: "/var/run",
            },
        },
        {
            name: "sys",
            hostPath: {
                path: "/sys",
            },
        },
        {
            name: "docker",
            hostPath: {
                path: "/var/lib/docker",
            },
        },
        {
            name: "disk",
            hostPath: {
                path: "/dev/disk",
            },
        },
    ],
    sfdc_scraper_volume_mounts():: [
        {
            mountPath: "/var/run",
            name: "var-run",
        },
        {
            name: "sys",
            mountPath: "/sys",
        },
        {
            mountPath: "/var/lib/docker",
            name: "docker",
        },
        {
            mountPath: "/dev/disk",
            name: "disk",
        },

    ],

    ## Service mesh volumes
    sherpa_volume_mounts():: [
        {
            mountPath: "/client-certs",
            name: "tls-client-cert",
        },
        {
            mountPath: "/server-certs",
            name: "tls-server-cert",
        },
    ],

    ### Init containers Definitions
    ## config gen container
    config_gen_rsyslog_init_container(config_name, template, manifest, output_path, env):: {
        local cmdline = if manifest == "" then
        [
            "/usr/bin/ruby",
            "/app/config_gen.rb",
            "-t",
            template,
            "-o",
            output_path,
        ]
        else
        [
            "/usr/bin/ruby",
            "/app/config_gen.rb",
            "-m",
            manifest,
        ],
        command: cmdline,
        name: "config-gen-" + config_name,
        image: images.config_gen,
        volumeMounts: $.rsyslog_config_volume_mounts() + $.rsyslog_config_gen_tpl_volume_mounts(),
        env: env,
    },

    config_gen_cadvisor_init_container(config_name, template, manifest, output_path, env)::
        $.config_gen_rsyslog_init_container(config_name, template, manifest, output_path, env) {
            volumeMounts: $.cadvisor_yaml_volume_mounts() + $.cadvisor_config_gen_tpl_volume_mounts(),
        },

    ## file based specific config gen
    config_gen_file_based_init_container(topic, log_type, file_path, owner, start_regex):: {
        local cmdline =
        [
            "/usr/bin/ruby",
            "/app/config_gen.rb",
            "-t",
            "/templates/rsyslog/general.conf.erb",
            "-o",
            "/etc/rsyslog.d/50-" + log_type + ".conf",
        ],
        command: cmdline,
        name: "config-gen-" + log_type,
        image: images.config_gen,
        volumeMounts: $.rsyslog_config_volume_mounts() + $.rsyslog_config_gen_tpl_volume_mounts(),
        env: [
            {
                name: "BROKER_VIP",
                valueFrom: {
                     configMapKeyRef: {
                        name: "kafka-cm",
                        key: "broker_vip",
                     },
                },
            },
            {
                name: "KAFKA_TOPIC",
                valueFrom: {
                     configMapKeyRef: {
                        name: "kafka-cm",
                        key: topic,
                     },
                },
            },
            {
                name: "LOG_TYPE",
                value: log_type,
            },
            {
                name: "FILE_PATH",
                value: file_path,
            },
            {
                name: "OWNER",
                value: owner,
            },
        ] + if start_regex != "" then [
            {
                name: "START_REGEX",
                value: start_regex,
            },
        ] else [],
    },

    ## Config check container
    config_check_init_container(image_name):: {
        command: [
            '/usr/sbin/rsyslogd',
            '-N1',
            '-f',
            '/etc/rsyslog.conf',
        ],
        name: "config-check",
        image: image_name,
        volumeMounts:
        [
            {
                name: "rsyslog-config-tpl",
                mountPath: "/etc/rsyslog.conf",
                subPath: "rsyslog.conf",
            },
        ] + $.rsyslog_config_volume_mounts() + $.rsyslog_volume_mounts(),
    },

    ### Service mesh container definition
    service_discovery_container():: {
        name: "sherpa",
        image: images.sherpa,
        args+: [] +
            if configs.estate == "gsf-core-devmvp-sam2-sam" then ["--switchboard=switchboard.service-mesh.svc:15001"]
            else if configs.estate == "gsf-core-devmvp-sam2-samtest" then ["--switchboard=switchboard-test.service-mesh.svc.sam.core.test.us-central1.gcp.sfdc.net:15001"]
            else [],
        env: [
            {
                name: "SFDC_ENVIRONMENT",
                value: "mesh",
            },
            {
                name: "SETTINGS_SERVICENAME",
                value: "cadvisor-exporter-daemonset",
            },
            {
                name: "FUNCTION_NAMESPACE",
                valueFrom: {
                    fieldRef: {
                        apiVersion: "v1",
                        fieldPath: "metadata.namespace",
                    },
                },
            },
            {
                name: "FUNCTION_INSTANCE_NAME",
                valueFrom: {
                    fieldRef: {
                        apiVersion: "v1",
                        fieldPath: "metadata.name",
                    },
                },
            },
            {
                name: "FUNCTION_INSTANCE_IP",
                valueFrom: {
                    fieldRef: {
                        apiVersion: "v1",
                        fieldPath: "status.podIP",
                    },
                },
            },
            {
                name: "FUNCTION",
                value: "cadvisor-exporter-daemonset",
            },
            {
                name: "KINGDOM",
                value: configs.kingdom,
            },
            {
                name: "ESTATE",
                value: configs.estate,
            },
            {
                name: "SUPERPOD",
                value: '-',
            },
            {
                name: "SETTINGS_SUPERPOD",
                value: '-',
            },
            {
                name: "SETTINGS_PATH",
                value: 'mesh.-.mvp.-.cadvisor-exporter-daemonset',
            },
            {
                name: "SFDC_SETTINGS_PATH",
                value: 'mesh.-.mvp.-.cadvisor-exporter-daemonset',
            },
            {
                name: "SFDC_METRICS_SERVICE_HOST",
                value: 'funnel.ajnalocal1.vip.core.test.us-central1.gcp.sfdc.net',
            },
            {
                name: "SFDC_METRICS_SERVICE_PORT",
                value: '443',
            },
        ],
        resources: {
            requests: {
                memory: "1Gi",
                cpu: "1",
            },
            limits: {
                memory: "1Gi",
                cpu: "1",
            },
        },
        ports: [
            {
                name: "grpc-in",
                containerPort: 7012,
            },
            {
                name: "grpc-tls-in",
                containerPort: 7443,
            },
            {
                name: "sherpa-adm",
                containerPort: 15373,
            },
        ],
        livenessProbe: {
          exec: {
            command: [
                './bin/is-alive',
            ],
          },
          initialDelaySeconds: 20,
          periodSeconds: 5,
        },
        readinessProbe: {
          exec: {
            command: [
                './bin/is-ready',
            ],
          },
          initialDelaySeconds: 15,
          periodSeconds: 5,
        },
        volumeMounts: $.sherpa_volume_mounts(),
    },
}
