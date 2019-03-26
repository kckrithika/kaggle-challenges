local configs = import "config.jsonnet";
local appNamespace = "sam-system";
// local rsyslogimages = import "rsyslogimages.libsonnet";
local rsyslogimages = (import "collection-agent-images.libsonnet") + { templateFilename:: std.thisFile };
local rsyslogutils = import "collection-agent-utils.jsonnet";
local madkub = (import "collection-agent-madkub.jsonnet") + { templateFilename:: std.thisFile };

local certDirs = ["cert1"];

local baseEnv = [
    {
        name: "BROKER_VIP",
        valueFrom: {
            configMapKeyRef: {
                name: "kafka-cm",
                key: "broker_vip",
            },
        },
    }
];

local defaultEnv = baseEnv + [
    {
        name: "KAFKA_TOPIC",
        valueFrom: {
            configMapKeyRef: {
                name: "kafka-cm",
                key: "general_topic",
            },
        },
    }
];

local casamEnv = baseEnv + [
    {
        name: "KAFKA_TOPIC",
        valueFrom: {
            configMapKeyRef: {
                name: "kafka-cm",
                key: "casam_topic",
            },
        },
    }
];

local initContainers = [
    madkub.madkubInitContainer(certDirs),
    # default container and journal configs
    rsyslogutils.config_gen_rsyslog_init_container(
        "default",
        "",
        "/templates/rsyslog/manifests.yaml",
        "",
        defaultEnv
    ),
    rsyslogutils.config_gen_rsyslog_init_container(
        "casam",
        "/templates/rsyslog/core.conf.erb",
        "",
        "/etc/rsyslog.d/50-casam.conf",
        casamEnv
    ),
    # general file based configs
    rsyslogutils.config_gen_file_based_init_container(
        "solr_topic",
        "solr",
        "/home/sfdc/logs/solr/solr/*.gmt.log",
        "Search",
        "^([[:alnum:]]{1,})`[[:digit:]]{14}.[[:digit:]]{3}`",
    ),
    rsyslogutils.config_gen_file_based_init_container(
        "solr_topic",
        "solr-jetty",
        "/home/sfdc/logs/solr/jetty/*.jvmgc.log_*",
        "Search",
        "^([[:digit:]]{4}-(0[1-9]|1[0-2])-(0?[1-9]|[12][[:digit:]]|3[01]))([[:space:]]|T)(([01][[:digit:]]|2[0-3]):[0-5][[:digit:]]:([0-5][[:digit:]]|6[01]))[,|\\\\.][[:digit:]]{3}",
    ),
    rsyslogutils.config_gen_file_based_init_container(
        "general_topic",
        "casam-jvm",
        "/home/sfdc/logs/jvm/*.jvm.log_*",
        "casam",
        "",
    ),
    rsyslogutils.config_gen_file_based_init_container(
        "general_topic",
        "casam-jvmgc",
        "/home/sfdc/logs/jvm/*.jvmgc.log_*",
        "casam",
        "^([[:digit:]]{4}-(0[1-9]|1[0-2])-(0?[1-9]|[12][[:digit:]]|3[01]))([[:space:]]|T)(([01][[:digit:]]|2[0-3]):[0-5][[:digit:]]:([0-5][[:digit:]]|6[01]))[,|\\\\.][[:digit:]]{3}",
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
                annotations: {
                    "madkub.sam.sfdc.net/allcerts":
                    std.manifestJsonEx(
                    {
                        certreqs:
                            [
                                certReq
for certReq in madkub.madkubRsyslogCertsAnnotation(certDirs).certreqs
                            ],
                    }, " "
),
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
                        ] + rsyslogutils.rsyslog_config_volume_mounts() + rsyslogutils.rsyslog_volume_mounts() + madkub.madkubRsyslogCertVolumeMounts(certDirs),
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
                    madkub.madkubRefreshContainer(certDirs),
                ],
                volumes+: [
                    configs.maddog_cert_volume,
                ] + rsyslogutils.rsyslog_config_volume()
                  + rsyslogutils.rsyslog_config_gen_tpl_volume()
                  + rsyslogutils.rsyslog_volume()
                  + madkub.madkubRsyslogCertVolumes(certDirs)
                  + madkub.madkubRsyslogMadkubVolumes(),
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
