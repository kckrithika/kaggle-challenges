local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: configs.specWithKubeConfigAndMadDog {
                containers: [
                    configs.containerWithKubeConfigAndMadDog {
                        name: "armada-controller",
                        image: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-dva-rc/dva/armada/armada:55",
                        command: configs.filter_empty([
                            "./armadasvc",
                            "--armadaTemplatesGitOrgName=armada",
                            "--armadaTemplatesGitRepoName=armada-templates",
                            "--armadaTemplatesGitBranchName=master",
                            "--armadaRepoProvisioningTemplateFilePath=repo-provision",
                            "--armadaCITemplateFilePath=scone-app/ci/.strata.yml",
                            "--gusPollInterval=10",
                            "--secrets.certFile=" + configs.certFile,
                            "--secrets.keyFile=" + configs.keyFile,
                            "--secrets.caFile=" + configs.caFile,
                            "--secrets.ssEndpoint=secretservice.dmz.salesforce.com",
                            "--spinnakerAppPath=armadabox/msftteamint",
                        ]),
                        volumeMounts+: configs.filter_empty([
                            configs.cert_volume_mount,
                            configs.config_volume_mount,
                        ]),
                        env+: [
                            {
                                name: "GITHUB_TOKEN",
                                valueFrom: {
                                    secretKeyRef: {
                                        key: "token1.txt",
                                        name: "git",
                                    },
                                },
                            },
                            {
                                name: "GUS_PASSWORD",
                                valueFrom: {
                                    secretKeyRef: {
                                        key: "p.txt",
                                        name: "gus-cred",
                                    },
                                },
                            },
                            {
                                name: "GUS_USERNAME",
                                valueFrom: {
                                    secretKeyRef: {
                                        key: "username.txt",
                                        name: "gus-cred",
                                    },
                                },
                            },
                            {
                                name: "GUS_SECRET",
                                valueFrom: {
                                    secretKeyRef: {
                                        key: "secret.txt",
                                        name: "gus-cred",
                                    },
                                },
                            },
                            {
                                name: "GUS_KEY",
                                valueFrom: {
                                    secretKeyRef: {
                                        key: "key.txt",
                                        name: "gus-cred",
                                    },
                                },
                            },
                        ],
                    },
                ],
                serviceAccount: "armada-sa",
                serviceAccountName: "armada-sa",
                volumes+: configs.filter_empty([
                    configs.cert_volume,
                    configs.config_volume("armada-controller"),
                    {
                      name: "gus-cred",
                      secret: {
                        defaultMode: 420,
                        secretName: "gus-cred",
                      },
                    },
                    {
                      name: "git",
                      secret: {
                        defaultMode: 420,
                        secretName: "git",
                      },
                    },
                ]),
            } + configs.serviceAccount
             + configs.nodeSelector,
            metadata: {
                labels: {
                    name: "armadacontroller",
                    apptype: "control",
                } + configs.ownerLabel.sam,
                namespace: "sam-system",
            },
        },
        selector: {
            matchLabels: {
                name: "armadacontroller",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "armadacontroller",
        } + configs.ownerLabel.sam,
        name: "armadacontroller",
    },
} else "SKIP"
