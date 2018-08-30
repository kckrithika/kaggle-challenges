local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local configs = import "config.jsonnet";

if !flowsnakeconfig.is_minikube then
"SKIP"
else
configs.deploymentBase("flowsnake") {
  metadata: {
      labels: {
          service: "maddog-onebox",
      },
      name: "maddog-onebox",
      namespace: "flowsnake",
  },
  spec+: {
        replicas: 1,
        strategy: {
            type: "Recreate",
        },
        template: {
            metadata: {
                labels: {
                    service: "maddog-onebox",
                },
            },
            spec: {
                containers: [
                    {
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/cdebains/maddog-onebox:willversion",
                        name: "maddog-onebox",
                        imagePullPolicy: flowsnakeconfig.default_image_pull_policy,
                        ports: [
                            {
                                containerPort: 8443,
                            },
                        ],
                        volumeMounts: [
                            {
                                mountPath: "/tmp/sc_repo",
                                name: "maddog-onebox-certs",
                            },
                        ],
                    },
                ],
                volumes: [
                    {
                        name: "maddog-onebox-certs",
                        hostPath: {
                                path: "/tmp/sc_repo",
                        },
                    },
                ],
            },
        },
    },
}
