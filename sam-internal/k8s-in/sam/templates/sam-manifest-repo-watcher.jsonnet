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
                                    },
                                ],
                                volumes: configs.filter_empty([
                                    configs.config_volume("sam-manifest-repo-watcher"),
                                ]),
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
