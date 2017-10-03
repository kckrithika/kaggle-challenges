local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

# Turned off by default.  Enable only when needed for a prod issue
if "0"=="1" then {
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                # We need this so we can mutate kubeconfig
                securityContext: {
                  runAsUser: 0,
                  fsGroup: 0,
                },
                hostNetwork: true,
                containers: [
                    {
                        image: samimages.hypersam,
                        command: [
                            "/bin/bash",
                            "-xe",
                            "/config/ops-adhoc.sh",
                        ],
                        name: "ops-adhoc",
                        resources: {
                            requests: {
                                cpu: "0.5",
                                memory: "300Mi"
                            },
                            limits: {
                                cpu: "0.5",
                                memory: "300Mi"
                            }
                          },
                        volumeMounts: configs.filter_empty([
                             configs.kube_config_volume_mount,
                             configs.config_volume_mount,
                        ])
                    }
                ],
                volumes: configs.filter_empty([
                   configs.kube_config_volume,
                   configs.config_volume("ops-adhoc"),
                ])
            },
            metadata: {
                labels: {
                    app: "ops-adhoc",
                    daemonset: "true",
                },
               "namespace": "sam-system"
            }
        }
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "ops-adhoc"
        },
        name: "ops-adhoc"
    }
} else
  "SKIP"
