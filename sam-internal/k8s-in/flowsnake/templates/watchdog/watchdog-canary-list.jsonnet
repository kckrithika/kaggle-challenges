local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local configs = import "config.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local madkub_common = import "madkub_common.jsonnet";
local watchdog = import "watchdog.jsonnet";
local enabled_canary_versions = [ ver for ver in watchdog.watchdog_canary_versions if std.objectHas(flowsnake_images.version_mapping.main, ver)];
local cert_name = "watchdogcanarycerts";

if ! watchdog.watchdog_enabled || std.length(enabled_canary_versions) < 1 then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "List",
    metadata: {},
    items: [
        local canary_version_name_token = std.join("-", std.split(canary_version, "."));
        configs.deploymentBase("flowsnake") {
            local label_node = self.spec.template.metadata.labels,
            metadata: {
                labels: {
                    name: "watchdog-canary",
                },
                name: "watchdog-canary-" + canary_version_name_token,
                namespace: "flowsnake",
            },
            spec+: {
                selector: {
                    matchLabels: {
                        app: label_node.app,
                        apptype: label_node.apptype,
                    }
                },
                template: {
                    metadata: {
                        annotations: {
                            "madkub.sam.sfdc.net/allcerts": std.toString({
                                certreqs: [
                                    {
                                        name: cert_name,
                                        role: "flowsnake_test",
                                        "cert-type": "client",
                                        kingdom: kingdom,
                                    }
                                ]
                            }),
                        },
                        labels: {
                            app: "watchdog-canary-" + canary_version_name_token,
                            apptype: "monitoring",
                            flowsnakeOwner: "dva-transform",
                            flowsnakeRole: "WatchdogCanary-" + canary_version_name_token
                        },
                    },
                    spec: {
                        restartPolicy: "Always",
                        hostNetwork: true,
                        containers: [
                            {
                                image: flowsnake_images.watchdog_canary,
                                imagePullPolicy: flowsnakeconfig.default_image_pull_policy,
                                command: [
                                    "/sam/watchdog",
                                    "-role=CLI",
                                    "-emailFrequency=" + watchdog.watchdog_email_frequency,
                                    "-timeout=2s",
                                    "-funnelEndpoint=" + flowsnakeconfig.funnel_vip_and_port,
                                    "--config=/config/watchdog.json",
                                    "-cliCheckerCommandTarget=" + canary_version,
                                    "--hostsConfigFile=/sfdchosts/hosts.json",
                                    "-watchdogFrequency=15m",
                                    "-alertThreshold=45m",
                                    "-cliCheckerTimeout=15m",
                                ],
                                name: "watchdog-canary",
                                resources: {
                                    requests: {
                                        cpu: "1",
                                        memory: "500Mi",
                                    },
                                    limits: {
                                        cpu: "1",
                                        memory: "500Mi",
                                    },
                                },
                                volumeMounts: [ configs.config_volume_mount, ]
                                  + madkub_common.cert_mounts(cert_name)
                                  + certs_and_kubeconfig.platform_cert_volumeMounts
                                  + [ watchdog.sfdchosts_volume_mount ],
                            },
                            ] + [ madkub_common.refresher_container(cert_name) ],
                        initContainers: [ madkub_common.init_container(cert_name), ],
                        volumes: [
                          {
                            configMap: {
                              name: "watchdog",
                            },
                            name: "config",
                          },
                        ]
                          + madkub_common.cert_volumes(cert_name)
                          + [ watchdog.sfdchosts_volume ],
                    },
                }
            }
        }
        for canary_version in enabled_canary_versions
    ]
}
