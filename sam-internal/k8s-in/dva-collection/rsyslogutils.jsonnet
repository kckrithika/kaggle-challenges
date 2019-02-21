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
}
    