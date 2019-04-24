local configs = import "config.jsonnet";
local appNamespace = "sam-system";
local ocagentimages = (import "collection-agent-images.libsonnet") + { templateFilename:: std.thisFile };
local ocagentutils = import "collection-agent-utils.jsonnet";
local madkub = (import "collection-agent-madkub.jsonnet") + { templateFilename:: std.thisFile };

local certDirs = ["client-certs", "server-certs"];

local configGenEnv = [
    {
        name: "KINGDOM",
        value: "MVP",
    },
];

local initContainers = [
    madkub.madkubInitContainer(certDirs),
    # default container and journal configs
    ocagentutils.config_gen_ocagent_init_container(
        "ocagent",
        "/templates/ocagent/opencensus.cadvisor.kubelet.yaml.erb",
        "",
        "/etc/opencensus/opencensus.config.yaml",
        configGenEnv
    ),
    madkub.permissionSetterInitContainer,
];

if configs.kingdom == "mvp" then {
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        name: "ocagent-daemonset",
        namespace: appNamespace,
        labels: {} + configs.pcnEnableLabel,
        annotations: {
            "seccomp.security.alpha.kubernetes.io/pod": "docker/default",
        },
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
                terminationGracePeriodSeconds: 30,
                # init containers
                initContainers: initContainers,
                containers: [
                    {
                        name: "ocagent",
                        imagePullPolicy: "Always",
                        image: ocagentimages.ocagent,
                        ports: [
                            {
                                containerPort: 55679,
                            },
                        ],
                        command: [
                            'ocagent',
                            '--config=/etc/opencensus/opencensus.config.yaml',
                        ],
                        livenessProbe: {
                            httpGet: {
                                path: "/debug/rpcz",
                                port: 55679,
                            },
                            initialDelaySeconds: 15,
                            periodSeconds: 120,
                        },
                        resources: {
                            requests: {
                                memory: "100Mi",
                                cpu: "150m",
                            },
                            limits: {
                                cpu: "300m",
                            },
                        },
                        volumeMounts:
                        [] + ocagentutils.ocagent_config_volume_mounts() + madkub.madkubRsyslogCertVolumeMounts(certDirs),
                    },
                    ocagentutils.service_discovery_container(),
                    madkub.madkubRefreshContainer(certDirs),
                ],
                volumes+: [
                    configs.maddog_cert_volume,
                ] + ocagentutils.ocagent_config_volume()
                  + ocagentutils.ocagent_config_gen_tpl_volume()
                  + madkub.madkubRsyslogCertVolumes(certDirs)
                  + madkub.madkubRsyslogMadkubVolumes(),
            },
        },
        updateStrategy: {
            rollingUpdate: {
                maxUnavailable: 1,
            },
            type: "RollingUpdate",
        },
    },
} else "SKIP"
