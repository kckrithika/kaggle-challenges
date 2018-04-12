local flowsnakeconfig = import "flowsnake_config.jsonnet";
if !flowsnakeconfig.is_minikube then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        labels: {
            service: "maddog-onebox",
        },
        name: "maddog-onebox",
        namespace: "flowsnake",
    },
    spec:
      {
          ports: [
              {
                  name: "8443",
                  port: 8443,
                  targetPort: 8443,
              },
          ],
          selector: {
              service: "maddog-onebox",
          },
      },
}
