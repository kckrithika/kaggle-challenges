local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };

local script = [
    "/config/slb-hosts-updater.sh",
    // The host name of the registry to override.
    configs.registry,
    // The host name of the F5 registry.
    slbconfigs.bootstrapRegistry,
    // The interval at which to update the hosts file.
    "60",
];

if slbconfigs.isSlbEstate then configs.daemonSetBase("slb") {
    spec+: {
        template: {
            spec: {
                containers: [
                    {
                        image: slbimages.hypersdn_ipvs_bootstrap,
                        command: [
                            "/bin/bash",
                        ] + script,
                        name: "slb-ipvs-artifactory-bootstrap",
                        resources: {
                            requests: {
                                cpu: "0.5",
                                memory: "300Mi",
                            },
                            limits: {
                                cpu: "0.5",
                                memory: "300Mi",
                            },
                        },
                        volumeMounts: [
                            {
                                name: "host-etc-volume",
                                mountPath: "/host-etc",
                            },
                            configs.config_volume_mount,
                        ],
                        env: [
                            // Bump this value whenever the script needs to be updated.
                            {
                                name: "IMMUTABLE_DEPLOYMENTS_ARE_GOOD",
                                value: "1",
                            },
                        ],
                    } + configs.ipAddressResourceRequest,
                ],
                volumes: [
                    {
                        name: "host-etc-volume",
                        hostPath: {
                            path: "/etc",
                        },
                    },
                    configs.config_volume("slb-ipvs-artifactory-bootstrap"),
                ],
                nodeSelector: {
                    // Only need to run this on ipvs nodes.
                    "slb-service": "slb-ipvs",
                },
            } + slbconfigs.getGracePeriod()
              + slbconfigs.getDnsPolicy(),
            metadata: {
                labels: {
                    name: "slb-ipvs-artifactory-bootstrap",
                    daemonset: "true",
                } + configs.ownerLabel.slb,
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
            name: "slb-ipvs-artifactory-bootstrap",
        } + configs.ownerLabel.slb,
        name: "slb-ipvs-artifactory-bootstrap",
        namespace: "sam-system",
    },
} else
    "SKIP"
