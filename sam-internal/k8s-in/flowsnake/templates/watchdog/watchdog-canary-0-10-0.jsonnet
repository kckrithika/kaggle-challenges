local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local configs = import "config.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local madkub_common = import "madkub_common.jsonnet";
local watchdog = import "watchdog.jsonnet";
if !std.objectHas(flowsnake_images.feature_flags, "watchdog_canaries") || !watchdog.watchdog_enabled then
"SKIP"
else
local cert_name = "watchdogcanarycerts";
{
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "watchdog-canary",
        },
        name: "watchdog-canary",
        namespace: "flowsnake",
    },
    kind: "Deployment",
    spec: {
        template: {
            metadata: {
                annotations: {
                    "madkub.sam.sfdc.net/allcerts": std.toString({
                        certreqs: [
                            {
                                name: cert_name,
                                role: "flowsnake_test",
                                san: [
                                    flowsnakeconfig.fleet_vips[estate],
                                    flowsnakeconfig.fleet_api_roles[estate] + ".flowsnake.localhost.mesh.force.com"
                                ],
                                "cert-type": "client",
                                kingdom: kingdom
                            }
                        ]
                    }),
                },
                labels: {
                    app: "watchdog-canary-0-10-0",
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
                            "-watchdogFrequency=10m",
                            "-alertThreshold=30m",
                            "-emailFrequency=" + watchdog.watchdog_email_frequency,
                            "-timeout=2s",
                            "-funnelEndpoint=" + flowsnakeconfig.funnel_vip_and_port,
                            "--config=/config/watchdog.json",
                            "-cliCheckerCommandTarget=0.10.0",
                            "-cliCheckerTimeout=10m",
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
                        volumeMounts: [
                            configs.config_volume_mount,
                            madkub_common.certs_mount,
                        ] + certs_and_kubeconfig.platform_cert_volumeMounts,
                    },
                    madkub_common.refresher_container(cert_name)
                ],
                initContainers: [
                    madkub_common.init_container(cert_name)
                ],
                volumes: [
                  {
                    configMap: {
                      name: "watchdog",
                    },
                    name: "config",
                  },
                  madkub_common.certs_volume,
                  madkub_common.tokens_volume,
                ] +
                certs_and_kubeconfig.platform_cert_volume,
            },
        },
    }
}