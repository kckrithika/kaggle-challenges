local configs = import "config.jsonnet";

configs.deploymentBase("service-mesh") {
    metadata+: {
      name: "route-update-service",
      namespace: "service-mesh",
    },
    spec+: {
      replicas: 2,
      template: {
        metadata: {
          labels: {
            app: "route-update-service",
          }
        },
        spec: {
          serviceAccountName: "route-update-service-service-account",
          containers: [
          {
              name: "route-update-service",
              image: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-sfci-dev/sfci/servicemesh/servicemesh/route-update-service:5b22f90645d766fb1e6cbc35012215678cbd539f",
              imagePullPolicy: "IfNotPresent",
              args: [],
              ports: [
                {
                  containerPort: 7020,
                },
              ],
              readinessProbe: {
                exec: {
                  command: [
                    "/bin/true",
                  ],
                },
                initialDelaySeconds: 5,
                periodSeconds: 30,
                timeoutSeconds: 5,
              },
          }
          ],
        }
      }
    },
}
