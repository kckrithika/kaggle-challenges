local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
# Yeah, I know this is not a watchdog.  Will fix with a refactor
local wdconfig = import "samwdconfig.jsonnet";

{
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
                    master: "true",
                },
            },
            metadata: {
                labels: {
                    name: "etcdbackup",
                    daemonset: "true",
                } + configs.ownerLabel.sam,
            },
        },
        [if configs.estate == "prd-samdev" || configs.estate == "prd-samtest" then "updateStrategy"]: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: "25%",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "etcdbackup",
        } + configs.ownerLabel.sam,
        name: "etcdbackup",
    },
}
