local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.sdpv1 then {
    kind: "Deployment",
    spec: {
        replicas: 2,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "sam-deployment-portal",
                        image: samimages.hypersam,
                        command: configs.filter_empty([
                            "/sam/sam-deployment-portal",
                            configs.sfdchosts_arg,
                            "--alsologtostderr",
                            # This was putting a ton of traffic on GHE, and its not clear it even works
                            # Will be replaced soon by SDPv2
                            "--latency-tolerance=301h",
                            "--gitPollPeriod=300h",
                            '--globalRedirect=Moved to http://sfdc.co/samportal',
                        ]),
                        ports: [
                            {
                                containerPort: 64121,
                            },
                        ],
                        volumeMounts+: [
                            configs.sfdchosts_volume_mount,
                            configs.cert_volume_mount,
                            {
                                mountPath: "/var/token",
                                name: "token",
                                readOnly: true,
                            },
                        ],
                        livenessProbe: {
                            initialDelaySeconds: 15,
                            httpGet: {
                                path: "/",
                                port: 64121,
                            },
                            timeoutSeconds: 10,
                        },
                        workingDir: "/sam",
                    },
                ],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    {
                        secret: {
                            secretName: "git-token",
                        },
                        name: "token",
                    },
                ],
                nodeSelector: {
                              } +
                              if configs.kingdom == "prd" then {
                                  master: "true",
                              } else {
                                  pool: configs.estate,
                              },
            },
            metadata: {
                labels: {
                    name: "sam-deployment-portal",
                    apptype: "control",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "sam-deployment-portal",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "sam-deployment-portal",
        } + configs.ownerLabel.sam,
        name: "sam-deployment-portal",
        namespace: "sam-system",
    },
} else "SKIP"
