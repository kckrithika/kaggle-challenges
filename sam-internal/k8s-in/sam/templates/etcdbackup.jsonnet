local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
# Yeah, I know this is not a watchdog.  Will fix with a refactor
local wdconfig = import "samwdconfig.jsonnet";
local featureflags = import "sam-feature-flags.jsonnet";
local maddogcertsmount = if featureflags.etcd3 then 'maddog-certs' else null;
local volumemounts = std.prune(['backup', 'cowdata', maddogcertsmount]);
local volumemountpoints = {
  backup: '/data/etcdbackup',
  cowdata: '/cowdata',
  'maddog-certs': '/etc/pki_service',
};

configs.daemonSetBase("sam") {
    spec+: {
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
                                name: x,
                                mountPath: volumemountpoints[x],
                            }
                            for x in volumemounts
                        ]),
                        env: [
                            configs.kube_config_env,
                        ],
                    },
                ],
                volumes: configs.filter_empty([
                    {
                        hostPath: {
                            path: volumemountpoints[x],
                        },
                        name: x,
                    }
                    for x in volumemounts
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
        updateStrategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: "25%",
            },
        },
    },
    metadata+: {
        labels: {
            name: "etcdbackup",
        } + configs.ownerLabel.sam,
        name: "etcdbackup",
    },
}
