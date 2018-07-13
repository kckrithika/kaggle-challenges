local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sam" then {
        kind: "Deployment",
        apiVersion: "extensions/v1beta1",
        metadata: {
            name: "sam-manifest-repo-watcher",
            labels: {
                name: "sam-manifest-repo-watcher",
            } + configs.ownerLabel.sam,
            namespace: "sam-system",
        },
        spec: {
            replicas: 1,
            template: {
                metadata: {
                    labels: {
                        name: "sam-manifest-repo-watcher",
                        apptype: "control",
                    },
                },
                spec: {
                    hostNetwork: true,
                    containers: [{
                        name: "sam-manifest-repo-watcher",
                        image: samimages.hypersam,
                        command: [
                            "/sam/sam-manifest-repo-watcher",
                            "--config=/config/sammanifestrepowatcher.json",
                            "--v=99",
                            "--alsologtostderr",
                        ],
                        volumeMounts: configs.filter_empty([
                            configs.config_volume_mount,
                            {
                                mountPath: "/var/mysqlPwd",
                                name: "mysql",
                                readOnly: true,
                            },
                            {
                                mountPath: "/var/token",
                                name: "token",
                                readOnly: true,
                            },
                            {
                                mountPath: "/var/webhook-token",
                                name: "webhook-token",
                                readOnly: true,
                            },
                        ]),
                        livenessProbe: {
                            httpGet: {
                                path: "/",
                                port: 8099,
                            },
                            initialDelaySeconds: 20,
                            periodSeconds: 10,
                            timeoutSeconds: 10,
                        },
                    }],
                    volumes: configs.filter_empty([
                        configs.config_volume("sam-manifest-repo-watcher"),
                        {
                            secret: {
                                secretName: "mysql-pwd",
                            },
                            name: "mysql",
                        },
                        {
                            secret: {
                              secretName: "git-token",
                            },
                            name: "token",
                        },
                        {
                            secret: {
                              secretName: "webhook-token",
                            },
                            name: "webhook-token",
                        },
                    ]),
                    nodeSelector: {
                                  } +
                                  if configs.kingdom == "prd" then {
                                      master: "true",
                                  } else {
                                      pool: configs.estate,
                                  },
                },

            },
        },
} else "SKIP"
