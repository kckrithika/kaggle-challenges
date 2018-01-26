local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";
# Yeah, I know this is not a watchdog.  Will fix with a refactor
local wdconfig = import "samwdconfig.jsonnet";

if configs.estate == "prd-samdev" then {
    kind: "DaemonSet",
    spec: {
        template: {
            spec: {
                securityContext: {
                    runAsUser: 0,
                    fsGroup: 0,
                },
                hostNetwork: true,
                containers: [
                    {
                        image: samimages.hypersam,
                        command: [
                            "/sam/etcdbackup.sh",
                        ],
                        name: "etcdbackup",
                        volumeMounts: configs.filter_empty([
                        {
                              name: "backup",
                              mountPath: "/data/etcdbackup",
                          },
                          {
                              name: "cowdata",
                              mountPath: "/cowdata",
                          },
                       ]),
                       env: [
                          configs.kube_config_env,
                       ],
                    },
                ],
                volumes: configs.filter_empty([
                {
                    hostPath: {
                        path: "/data/etcdbackup",
                    },
                    name: "backup",
                    },

                    {
                        hostPath: {
                            path: "/cowdata",
                        },
                        name: "cowdata",
                    },
                ]),
                nodeSelector: {
                    etcd_installed: "true",
                },
            },
            metadata: {
                labels: {
                    name: "etcdbackup",
                    daemonset: "true",
                },
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "etcdbackup",
        },
        name: "etcdbackup",
    },
} else "SKIP"
