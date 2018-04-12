local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
if !flowsnakeconfig.is_minikube then
"SKIP"
else
{
  apiVersion: "extensions/v1beta1",
  kind: "Deployment",
  metadata: {
      labels: {
          service: "maddog-onebox",
      },
      name: "maddog-onebox",
      namespace: "flowsnake",
  },
  spec: {
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
            imagePullPolicy: "Never",
            ports: [
              {
                containerPort: 8443,
              },
            ],
            volumeMounts: [
              {
                mountPath: "/tmp/sc_repo",
                name: "maddog-onebox-claim",
              },
            ],
          },
        ],
        volumes: [
          {
            name: "maddog-onebox-claim",
            persistentVolumeClaim: {
                claimName: "maddog-onebox-claim",
            },
          },
        ],
      },
    },
  },
}
