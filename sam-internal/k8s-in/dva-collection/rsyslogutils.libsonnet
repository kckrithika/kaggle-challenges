local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

// Public functions
{
    config_gen_volume():: [
        {
            name: "rsyslog-config",
            emptyDir: {},
        },
        {
            name: "config-generator-volume",
            //configMap: {
            //    name: "rsyslog-daemonset-configmap"
            //},
            emptyDir: {},
        },
    ],
    config_gen_volume_mounts():: [
        {
            mountPath: "/etc/app.conf.d",
            name: "rsyslog-config"
        },
        {
            mountPath: "/opt/config-gen",
            name: "config-generator-volume",
        }
    ],
    rsyslog_volume():: [
        {
            name: "varlog",
            hostPath: {
                path: "/var/log"
            },
        },
        {
            name: "varlibdockercontainers",
            hostPath: {
                path: "/var/lib/docker/containers"
            },
        },
        {
            name: "rsyslog-workdir",
            emptyDir: {},
        },
        {
            name: "rsyslog-imjournal",
            hostPath: {
                path: "/var/log/journal"
            },
        }
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
            mountPath: "/var/spool/rsyslog",
            name: "rsyslog-workdir",
        },
        {
            mountPath: "/run/log/journal",
            name: "rsyslog-imjournal",
        }

    ]

    ### Init containers Definitions
    config_gen_init_container(image_name, template, manifest, output_path):: {
        local cmdline = if manifest == "" then
                "-t " + template + " -o " + output_path
            else
                "-m " + manifest + " -o " + output_path,
        command: [
            "/usr/bin/ruby,
            "/opt/config-gen/config_gen.rb" + cmdline,
        ],
        name: "config-gen",
        image: image_name,
        volumeMounts: rsyslogutils.config_gen_volume_mounts(),
        env: [
            {
                name: "BROKER_VIP",
                value: kafka_vip_from_yaml,
            },
            {
                name: "KAFKA_TOPIC",
                value: kafka_topic_from_yaml,
            },
        ],
    },
}
    