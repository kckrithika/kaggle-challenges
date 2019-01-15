local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local configs = import "config.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local madkub_common = import "madkub_common.jsonnet";
local watchdog = import "watchdog.jsonnet";
local remove_suspect_sans = std.objectHas(flowsnake_images.feature_flags, "remove_suspect_sans");
if !watchdog.watchdog_enabled then
"SKIP"
else
local cert_name = "watchdogcanarycerts";
configs.deploymentBase("flowsnake") {
    metadata: {
        labels: {
            name: "watchdog-canary",
        },
        name: "watchdog-canary-0-11-0",
        namespace: "flowsnake",
    },
    spec+: {
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
                            } + if remove_suspect_sans then {} else {
                                # Why do we have SANs here? Can we remove them?
                                san: [
                                    flowsnakeconfig.fleet_vips[estate],
                                    flowsnakeconfig.service_mesh_fqdn("api"),
                                ],
                            }
                        ]
                    }),
                },
                labels: {
                    app: "watchdog-canary-0-11-0",
                    apptype: "monitoring"
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
                            "-cliCheckerCommandTarget=0.11.0",
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
        },
    }
}
