local configs = import "config.jsonnet";
local appNamespace = "sam-system";
local cadvisorimages = (import "collection-agent-images.libsonnet") + { templateFilename:: std.thisFile };
local cadvisorutils = import "collection-agent-utils.jsonnet";

local scraperInitEnv = [
    {
        name: "FORWARD_PORT",
        value: "2003",

    },
    {
        name: "CADVISOR_PORT",
        value: "8080",

    },
    {
        name: "CADVISOR_HOST",
        value: "localhost",

    },
];

local forwarderInitEnv = [
    {
        name: "LISTEN_PORT",
        value: "2003",

    },
    {
        name: "FUNNEL_VIP",
        value: "ajnafunneldirecttls.funnel.localhost.mesh.force.com",

    },
    {
        name: "FUNNEL_PORT",
        value: "5442",

    },
    {
        name: "FUNNEL_HTTPS",
        value: "off",

    },

];
local initContainers = [
    cadvisorutils.config_gen_cadvisor_init_container(
        "scraper",
        "/templates/cadvisor/scraper.yaml.erb",
        "",
        "/etc/cadvisor/scraper.yaml",
        scraperInitEnv
    ),
    cadvisorutils.config_gen_cadvisor_init_container(
        "forwarder",
        "/templates/cadvisor/forwarder.conf.erb",
        "",
        "/etc/rsyslog.d/30-forwarder.conf",
        forwarderInitEnv
    ),
];

if configs.kingdom == "mvp" then {
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        name: "cadvisor-exporter-daemonset",
        namespace: appNamespace,
        annotations: {
            "seccomp.security.alpha.kubernetes.io/pod": "docker/default",
        },
        labels: {} + configs.pcnEnableLabel,
    },
    spec: {
        selector: {
            matchLabels: {
                name: "cadvisor-exporter-daemonset",
            },
        },
        template: {
            metadata: {
                labels: {
                    name: "cadvisor-exporter-daemonset",
                },
            },
            spec: {
                automountServiceAccountToken: false,
                terminationGracePeriodSeconds: 30,
                # init containers
                initContainers: initContainers,
                containers: [
                    {
                        name: "rsyslog-funnel-forwarder",
                        image: cadvisorimages.rsyslog,
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
                        ports: [
                            {
                                containerPort: 2003,
                                protocol: "UDP",
                            },
                        ],
                        volumeMounts:
                        [
                            {
                                name: "cadvisor-config-tpl",
                                mountPath: "/etc/rsyslog.conf",
                                subPath: "rsyslog.conf",
                            },
                        ] + cadvisorutils.rsyslog_config_volume_mounts(),
                    },
                    {
                        name: "cadvisor-scraper",
                        image: cadvisorimages.cadvisor_scraper,
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
                        command: [
                            '/app/cadvisor_scraper.py',
                            '-f',
                            '/etc/cadvisor/scraper.yaml',
                        ],
                        volumeMounts: cadvisorutils.cadvisor_yaml_volume_mounts(),
                    },
                    {
                        name: "sfdc-cadvisor",
                        image: cadvisorimages.cadvisor,
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
                        ports: [
                            {
                                name: "http",
                                containerPort: 8080,
                                protocol: "TCP",
                            },
                        ],
                        volumeMounts: cadvisorutils.sfdc_scraper_volume_mounts(),
                    },
                    cadvisorutils.service_discovery_container(),
                ],
                volumes+: cadvisorutils.cadvisor_yaml_volume() +
                          cadvisorutils.cadvisor_config_gen_tpl_volume() +
                          cadvisorutils.sfdc_scraper_volume() +
                          cadvisorutils.sherpa_volume(),
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
