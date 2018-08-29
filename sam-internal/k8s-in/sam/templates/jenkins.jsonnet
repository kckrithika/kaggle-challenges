local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-samdev" then {

    kind: "Deployment",
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                containers: [
                    {
                        name: "jenkins",
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/tkuznets/jenkins:20180829",
                        volumeMounts: configs.filter_empty([
                            {
                                name: "docker",
                                mountPath: "/usr/bin/docker",
                            },
                            {
                                name: "kubectl",
                                mountPath: "/usr/bin/kubectl",
                            },
                            {
                                name: "dockersock",
                                mountPath: "/var/run/docker.sock",
                            },
                            {
                                name: "jenkins-home",
                                mountPath: "/var/jenkins_home",
                            },
                            {
                                name: "libsystemd-journal",
                                mountPath: "/usr/lib/x86_64-linux-gnu/libsystemd-journal.so.0",
                            },
                            {
                                name: "libsystemd-id128",
                                mountPath: "/usr/lib/x86_64-linux-gnu/libsystemd-id128.so.0",
                            },
                            {
                                name: "libdevmapper",
                                mountPath: "/usr/lib/x86_64-linux-gnu/libdevmapper.so.1.02",
                            },
                            {
                                name: "libgcrypt",
                                mountPath: "/usr/lib/x86_64-linux-gnu/libgcrypt.so.11",
                            },
                            {
                                name: "libdw",
                                mountPath: "/usr/lib/x86_64-linux-gnu/libdw.so.1",
                            },
                            {
                                name: "libltdl",
                                mountPath: "/usr/lib/x86_64-linux-gnu/libltdl.so.7",
                            },

                        ]),
                        ports: [
                            {
                                containerPort: 8080,
                                name: "jenkins",
                            },
                        ],
                    },
                ],
                volumes: [
                    {
                        hostPath: {
                            path: "/home/xiaozhou/jenkins_home",
                        },
                        name: "jenkins-home",
                    },
                    {
                        hostPath: {
                            path: "/usr/bin/docker",
                        },
                        name: "docker",
                    },
                    {
                        hostPath: {
                            path: "/usr/bin/kubectl",
                        },
                        name: "kubectl",
                    },
                    {
                        hostPath: {
                            path: "/var/run/docker.sock",
                        },
                        name: "dockersock",
                    },
                    {
                        hostPath: {
                            path: "/usr/lib64/libsystemd-journal.so.0",
                        },
                        name: "libsystemd-journal",
                    },
                    {
                        hostPath: {
                            path: "/usr/lib64/libdevmapper.so.1.02",
                        },
                        name: "libdevmapper",
                    },
                    {
                        hostPath: {
                            path: "/usr/lib64/libsystemd-id128.so.0",
                        },
                        name: "libsystemd-id128",
                    },
                    {
                        hostPath: {
                            path: "/usr/lib64/libgcrypt.so.11",
                        },
                        name: "libgcrypt",
                    },
                    {
                        hostPath: {
                            path: "/usr/lib64/libdw.so.1",
                        },
                        name: "libdw",
                    },
                    {
                        hostPath: {
                            path: "/usr/lib64/libltdl.so.7",
                        },
                        name: "libltdl",
                    },
                ],
                nodeSelector: {
                    "kubernetes.io/hostname": "shared0-samdevcompute1-1-prd.eng.sfdc.net",
                },
            },
            metadata: {
                labels: {
                    name: "jenkins",
                    apptype: "jenkins",
                } + configs.ownerLabel.sam,
            },
        },
        selector: {
            matchLabels: {
                name: "jenkins",
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        labels: {
            name: "jenkins",
        } + configs.ownerLabel.sam,
        name: "jenkins",
        namespace: "sam-system",
    },
} else "SKIP"
