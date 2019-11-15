local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-samdev" || configs.estate == "prd-samtwo" then {
    kind: "Deployment",
    apiVersion: "apps/v1beta1",
    spec: {
        replicas: 5,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                hostNetwork: true,
                  securityContext: {
                    runAsUser: 0,
                    fsGroup: 0,
                },
                nodeSelector: {
                    pool: configs.estate,
                },
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        command: [
                            "/sam/virtual-api",
                            "--config=/config/pseudo-kubeapi.json",
                        ],
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/d.smith/hypersam:20180518_123833.16f51950.dirty.duncsmith-ltm",
                        imagePullPolicy: "Always",
                        livenessProbe: {
                            failureThreshold: 3,
                            httpGet: {
                                path: "/healthz",
                                port: 7002,
                                scheme: "HTTP",
                            },
                            periodSeconds: 10,
                            successThreshold: 1,
                            timeoutSeconds: 1,
                        },
                        name: "pseudo-kubeapi",
                        ports: [
                            {
                                containerPort: 7002,
                                protocol: "TCP",
                            },
                        ],
                        terminationMessagePath: "/dev/termination-log",
                        terminationMessagePolicy: "File",
                        volumeMounts: [
                            {
                                mountPath: "/var/secrets/",
                                name: "mysql",
                                readOnly: true,
                            },
                        ],
                    },
                ],
                volumes+: [
                    configs.sfdchosts_volume,
                    configs.cert_volume,
                    {
                        name: "mysql",
                        secret: {
                            defaultMode: 420,
                            secretName: "mysql-passwords",
                        },
                    },
                ],
            },
            metadata: {
                labels: {
                    name: "pseudo-kubeapi",
                } + configs.ownerLabel.sam,
            },
        },
        selector: {
            matchLabels: {
                name: "pseudo-kubeapi",
            },
        },
    },
    metadata: {
        labels: {
            name: "pseudo-kubeapi",
        } + configs.ownerLabel.sam,
        name: "pseudo-kubeapi",
        namespace: "csc-sam",
    },
} else "SKIP"
