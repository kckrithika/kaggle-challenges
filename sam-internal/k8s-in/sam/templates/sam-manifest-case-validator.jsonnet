local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-sam" then configs.deploymentBase("sam") {
        metadata+: {
            name: "sam-manifest-case-validator",
            labels: {
                name: "sam-manifest-case-validator",
            } + configs.ownerLabel.sam,
            namespace: "default",
        },
        spec+: {
            replicas: 1,
            template: {
                metadata: {
                    labels: {
                        name: "sam-manifest-case-validator",
                        apptype: "control",
                    } + configs.ownerLabel.sam,
                },
                spec: {
                    hostNetwork: true,
                    dnsPolicy: "ClusterFirstWithHostNet",
                    containers: [{
                        name: "sam-manifest-case-validator",
                        image: samimages.hypersam,
                        command: [
                            "/sam/sam-manifest-case-validator",
                            "--config=/config/sammanifestcasevalidator.json",
                            "--v=99",
                            "--alsologtostderr",
                        ],
                        volumeMounts: configs.filter_empty([
                            configs.config_volume_mount,
                            {
                                mountPath: "/etc/webhook-secret",
                                name: "webhook-token",
                                readOnly: true,
                            },
                            {
                                mountPath: "/etc/git-secret",
                                name: "git-token",
                                readOnly: true,
                            },
                            {
                                mountPath: "/etc/gus-secrets",
                                name: "gus-secrets",
                                readOnly: true,
                            },
                        ]),
                    }],
                    volumes: configs.filter_empty([
                        configs.config_volume("sam-manifest-case-validator"),
                        {
                            secret: {
                                secretName: "case-validator-webhook-token",
                            },
                            name: "webhook-token",
                        },
                        {
                            secret: {
                              secretName: "case-validator-git-token",
                            },
                            name: "git-token",
                        },
                        {
                            secret: {
                              secretName: "case-validator-gus-secrets",
                            },
                            name: "gus-secrets",
                        },
                    ]),
                    nodeSelector: {
                                  } +
                                  if !utils.is_production(configs.kingdom) then {
                                      master: "true",
                                  } else {
                                      pool: configs.estate,
                                  },
                },
            },
        },
} else "SKIP"
