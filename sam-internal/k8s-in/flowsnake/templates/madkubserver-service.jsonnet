local flowsnakeconfig = import "flowsnake_config.jsonnet";
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        labels: {
            service: "madkubserver",
        },
        name: "madkubserver",
        namespace: "flowsnake",
    },
    spec:
    {
        selector: {
            service: "madkubserver",
        },
    } +
    (if flowsnakeconfig.is_minikube then
      {
          ports: [
              {
                  name: "32007",
                  port: 32007,
                  targetPort: 32007,
              },
          ],
      }
    else
      {
          clusterIP: "10.254.208.254",
          ports: [
              {
                  name: "madkubapitls",
                  port: 32007,
                  targetPort: 32007,
              },
          ],
      }),
    status: {
        loadBalancer: {},
    },
}
