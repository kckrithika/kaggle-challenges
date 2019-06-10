local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local configs = import "config.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_minikube || ! ("systemd_installer_enabled" in flowsnake_images.feature_flags) then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "List",
    metadata: {},
    items: [
        {
            kind: "ConfigMap",
            apiVersion: "v1",
            metadata: {
              name: "flowsnake-systemd-files",
              namespace: "flowsnake",
            },
            data: {
              "flowsnake.service": (importstr "flowsnake-systemd-unit.service"),
              "flowsnake-start.sh": (importstr "flowsnake-start.sh"),
              "flowsnake-stop.sh": (importstr "flowsnake-stop.sh"),
              "configure-systemd.sh": (importstr "configure-systemd.sh"),
            },
        },
        configs.daemonSetBase("flowsnake") {
            local label_node = self.spec.template.metadata.labels,
            apiVersion: "extensions/v1beta1",
            kind: "DaemonSet",
            metadata: {
                labels: {
                    name: "flowsnake-systemd-deployer",
                },
                name: "flowsnake-systemd-deployer",
                namespace: "flowsnake"
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
                            "sfdc.net/disable-madkub": "true"
                        },
                        labels: {
                            app: "flowsnake-systemd-deployer",
                            apptype: "testing",
                            daemonset: "true",
                            flowsnakeOwner: "dva-transform",
                            flowsnakeRole: "FlowsnakeSystemdDeployer"
                        }
                    },
                    spec: {
                        automountServiceAccountToken: true,
                        hostPID: true,
                        containers: [
                            {
                                command: [
                                    "sh",
                                    "-c",
                                    "/systemd-files/configure-systemd.sh"
                                ],
                                image: flowsnake_images.jdk8_base,
                                name: "agent",
                                resources: {
                                    requests: {
                                        cpu: "50m",
                                        memory: "1Mi"
                                    }
                                },
                                securityContext: {
                                    privileged: true
                                },
                                volumeMounts: [
                                    {
                                        mountPath: "/host",
                                        name: "host-path",
                                        readOnly: false
                                    },
                                    {
                                        mountPath: "/systemd-files",
                                        name: "flowsnake-systemd-files",
                                        readOnly: true
                                    }
                                ]
                            }
                        ],
                        restartPolicy: "Always",
                        volumes: [
                            {
                                hostPath: {
                                    path: "/",
                                },
                                name: "host-path"
                            },
                            {
                                configMap: {
                                    name: "flowsnake-systemd-files",
                                    # 493 -> 0755 (octal) -> rwxr-xr-x
                                    defaultMode: 493
                                },
                                name: "flowsnake-systemd-files"
                            }
                        ]
                    }
                }
            }
        }
    ]
}
