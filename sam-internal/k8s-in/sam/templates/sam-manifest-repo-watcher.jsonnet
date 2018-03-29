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
                                        name: "sam-manifest-repo-watcher",
                                        image: samimages.hypersam,
                                        command: configs.filter_empty([
                                            "/sam/sam-manifest-repo-watcher",
                                            "--config=/config/sammanifestrepowatcher.json",
                                        ]),
                                        volumeMounts: configs.filter_empty([
                                                    configs.config_volume_mount,
                                                    {
                                                            mountPath: "/var/mysqlPwd",
                                                            name: "mysql",
                                                            readOnly: true,
                                                        },
                                        ]) + (if configs.kingdom == "prd" then [
                                          {
                                              mountPath: "/var/token",
                                              name: "token",
                                              readOnly: true,
                                                  },
                                              ] else []),
                                    },
                                ],
                                volumes: configs.filter_empty([
                                    configs.config_volume("sam-manifest-repo-watcher"),
                                    {
                                            secret: {
                                                secretName: "mysql-pwd",
                                            },
                                            name: "mysql",
                                    },
                                ]) + (if configs.kingdom == "prd" then [
                                  {
                                      secret: {
                                          secretName: "git-token",
                                      },
                                      name: "token",
                                  },
                              ] else []),
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
                                    name: "sam-manifest-repo-watcher",
                                    apptype: "control",
                                },
                            },
                        },
                    },
        apiVersion: "extensions/v1beta1",
            metadata: {
                      labels: {
                        name: "sam-manifest-repo-watcher",
                },
        name: "sam-manifest-repo-watcher",
               namespace: "sam-system",
          },
} else "SKIP"
