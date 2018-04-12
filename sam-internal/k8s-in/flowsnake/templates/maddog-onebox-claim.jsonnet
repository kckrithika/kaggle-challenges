local flowsnakeconfig = import "flowsnake_config.jsonnet";
if !flowsnakeconfig.is_minikube then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "PersistentVolumeClaim",
    metadata: {
        labels: {
            service: "maddog-onebox-claim",
        },
        name: "maddog-onebox-claim",
        namespace: "flowsnake",
    },
    spec:
      {
          accessModes: [
              "ReadWriteOnce",
          ],
          resources: {
              requests: {
                  storage: "100Mi",
              },
          },
      },
}
