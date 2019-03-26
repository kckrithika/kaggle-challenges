local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";
local rsyslogimages = (import "rsyslogimages.libsonnet") + { templateFilename:: std.thisFile };

{
    // TODO declare as function for future optimazation by passing name and path
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
    config_gen_tpl_volume():: [
        {
            name: "rsyslog-config-tpl",
            configMap: {
                name: "rsyslog-configmap",
            },
        },
    ],
    config_gen_tpl_volume_mounts():: [
        {
            mountPath: "/templates",
            name: "rsyslog-config-tpl",
        },
    ],
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

    ### Init containers Definitions
    ## config gen container
    config_gen_init_container(config_name, template, manifest, output_path, topic):: {
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
        image: rsyslogimages.config_gen,
        volumeMounts: $.rsyslog_config_volume_mounts() + $.config_gen_tpl_volume_mounts(),
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
            }
        ],
    },

    config_gen_file_based_init_container(topic, log_type, file_path, owner, start_regex):: {
        local cmdline =
        [
            "/usr/bin/ruby",
            "/app/config_gen.rb",
            "-t",
            "/templates/general.conf.erb",
            "-o",
            "/etc/rsyslog.d/50-" + log_type + ".conf",
        ],
        command: cmdline,
        name: "config-gen-" + log_type,
        image: rsyslogimages.config_gen,
        volumeMounts: $.rsyslog_config_volume_mounts() + $.config_gen_tpl_volume_mounts(),
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
}
