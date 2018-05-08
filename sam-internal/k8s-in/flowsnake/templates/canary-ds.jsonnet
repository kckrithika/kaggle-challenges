local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_minikube_small then
"SKIP"
else
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
                        image: flowsnake_images.canary,
                        imagePullPolicy: flowsnakeconfig.default_image_pull_policy,
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
