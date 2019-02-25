local configs = import "config.jsonnet";
local appNamespace = "sam-system";
local rsyslogimages = import "rsyslogimages.jsonnet";
local rsyslogutils = import "rsyslogutils.jsonnet";

local config_gen_image = "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-devmvp/dva/collection-erb-config-gen:v0.1alpha2";
local rsyslog_image = "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-devmvp/dva/sfdc_rsyslog_gcp:8.38.0alpha1";

local initContainers = [
    rsyslogutils.config_gen_init_container(
        config_gen_image,
        "",
        "/opt/config-gen/manifest.yaml",
        "/etc/app.conf.d/"
    ),
];

if configs.kingdom == "mvp" then {
    apiVersion: "apps/v1",
    kind: "DaemonSet",
    metadata: {
        name: "rsyslog-daemonset",
        namespace: appNamespace
    },
    spec: {
        selector: {
            matchLabels: {
                app: "collection-agent-daemonset"
            }
        },
        template: {
            metadata: {
                labels: {
                    app: "collection-agent-daemonset"
                },
                spec: {
                    automountServiceAccountToken: false,
                    terminationGracePeriodSeconds: 60
                },
                # init containers
                initContainers: initContainers,
                containers: [
                    {
                        name: "rsyslog-daemonset",
                        imagePullPolicy: "Always",
                        image: rsyslog_image,
                        resources: {
                            requests: {
                                memory: "2Gi",
                                cpu: "500m"
                            }
                        },
                        volumeMounts:[] + rsyslogutils.rsyslog_volume_mounts() + rsyslogutils.config_gen_volume_mounts()
                    }
                ],
                volumes: [] + rsyslogutils.rsyslog_volume() + rsyslogutils.config_gen_volume()
            }
        },
        templateGeneration: 2,
        updateStrategy: {
            rollingUpdate: {
                maxUnavailable: 1,
                type: "RollingUpdate"
            }
        }
    }
} else "SKIP"
