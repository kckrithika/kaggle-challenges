local flowsnakeimage = import "flowsnake_images.jsonnet";
{
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        name: "canary",
        namespace: "default",
        labels: {
            name: "canary",
        },
    },
    spec: {
        template: {
            metadata: {
                labels: {
                    name: "canary",
                    app: "canary",
                },
            },
            spec: {
                containers: [
                    {
                        image: flowsnakeimage.canary,
                        imagePullPolicy: "IfNotPresent",
                        resources: {
                            requests: {
                                cpu: 0.1,
                                memory: "5M",
                            },
                        },
                        name: "canary",
                        readinessProbe: {
                            periodSeconds: 20,
                            exec: {
                                command: [
                                    "bash",
                                    "/run-checks.sh",
                                ],
                            },
                        },
                        volumeMounts: [
                            {
                                name: "empty",
                                mountPath: "/empty",
                            },
                            {
                                name: "proc",
                                mountPath: "/proc-host",
                                readOnly: true,
                            },
                        ],
                    },
                ],
                volumes: [
                    {
                        name: "empty",
                        emptyDir: {},
                    },
                    {
                        name: "proc",
                        hostPath: {
                            path: "/proc",
                        },
                    },
                ],
            },
        },
    },
}
