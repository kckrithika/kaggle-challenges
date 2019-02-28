local configs = import "config.jsonnet";
local appNamespace = "sam-system";
// local rsyslogimages = import "rsyslogimages.libsonnet";
local rsyslogimages = (import "rsyslogimages.libsonnet") + { templateFilename:: std.thisFile };
local rsyslogutils = import "rsyslogutils.jsonnet";

local volumes = rsyslogutils.rsyslog_config_volume() + rsyslogutils.config_gen_tpl_volume() + rsyslogutils.rsyslog_volume();

local initContainers = [
    rsyslogutils.config_gen_init_container(
        "journal",
        rsyslogimages.config_gen,
        "/templates/journal.conf.erb",
        "",
        "/etc/rsyslog.d/30-journal.conf",
        "general_topic"
    ),
    rsyslogutils.config_gen_init_container(
        "container",
        rsyslogimages.config_gen,
        "/templates/container.conf.erb",
        "",
        "/etc/rsyslog.d/40-container.conf",
        "general_topic"
    ),
    rsyslogutils.config_gen_init_container(
        "solr",
        rsyslogimages.config_gen,
        "/templates/solr.conf.erb",
        "",
        "/etc/rsyslog.d/50-solr.conf",
        "solr_topic"
    ),
    rsyslogutils.config_gen_init_container(
        "jetty",
        rsyslogimages.config_gen,
        "/templates/jetty.conf.erb",
        "",
        "/etc/rsyslog.d/50-solr_jetty.conf",
        "solr_topic"
    ),
    rsyslogutils.config_check_init_container(rsyslogimages.rsyslog),
];

if configs.kingdom == "mvp" then {
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        name: "rsyslog-daemonset",
        namespace: appNamespace,
        labels: {} + configs.pcnEnableLabel,
    },
    spec: {
        selector: {
            matchLabels: {
                app: "collection-agent-daemonset",
            },
        },
        template: {
            metadata: {
                labels: {
                    app: "collection-agent-daemonset",
                },
            },
            spec: {
                automountServiceAccountToken: false,
                terminationGracePeriodSeconds: 60,
                # init containers
                initContainers: initContainers,
                containers: [
                    {
                        name: "rsyslog-daemonset",
                        imagePullPolicy: "Always",
                        image: rsyslogimages.rsyslog,
                        resources: {
                            requests: {
                                memory: "200Mi",
                                cpu: "150m",
                            },
                            limits: {
                                memory: "1024Mi",
                                cpu: "300m",
                            },
                        },
                        volumeMounts:
                        [
                            {
                                name: "rsyslog-config-tpl",
                                mountPath: "/etc/rsyslog.conf",
                                subPath: "rsyslog.conf",
                            },
                        ] + rsyslogutils.rsyslog_config_volume_mounts() + rsyslogutils.rsyslog_volume_mounts(),
                    },
                    {
                        name: "logarchive",
                        imagePullPolicy: "Always",
                        image: rsyslogimages.logarchive,
                        command: [
                            '/usr/local/bin/sfdc_log_archiver',
                            '-dir',
                            '/home/sfdc/logs',
                        ],
                        volumeMounts: [
                            {
                                name: "logs-vol",
                                mountPath: "/home/sfdc/logs",
                            },
                        ],
                    },
                ],
                volumes: volumes,
            },
        },
        templateGeneration: 2,
        updateStrategy: {
            rollingUpdate: {
                maxUnavailable: 1,
            },
            type: "RollingUpdate",
        },
    },
} else "SKIP"
