local port_config = import "portconfig.jsonnet";
local estate = std.extVar("estate");

if estate == "prd-data-flowsnake" then
{
    apiVersion: "v1",
    items: [
       {
          apiVersion: "v1",
          kind: "Service",
          metadata: {
              labels: {
                  app: "dashboard-dfw",
              },
              name: "dashboard-dfw",
              namespace: "flowsnake",
          },
          spec: {
              ports: [
                  {
                      name: "tcp80",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9190,
                      nodePort: port_config.flowsnake.dashboard_dfw,
                  },
              ],
              selector: {
                  app: "dashboard",
              },
              type: "NodePort",
          },
       },
      {
         apiVersion: "v1",
         kind: "Service",
         metadata: {
             labels: {
                 app: "dashboard-frf",
             },
             name: "dashboard-frf",
             namespace: "flowsnake",
         },
         spec: {
             ports: [
                 {
                     name: "tcp80",
                     port: 80,
                     protocol: "TCP",
                     targetPort: 9191,
                     nodePort: port_config.flowsnake.dashboard_frf,
                 },
             ],
             selector: {
                 app: "dashboard",
             },
             type: "NodePort",
         },
      },
      {
         apiVersion: "v1",
         kind: "Service",
         metadata: {
             labels: {
                 app: "dashboard-hnd",
             },
             name: "dashboard-hnd",
             namespace: "flowsnake",
         },
         spec: {
             ports: [
                 {
                     name: "tcp80",
                     port: 80,
                     protocol: "TCP",
                     targetPort: 9192,
                     nodePort: port_config.flowsnake.dashboard_hnd,
                 },
             ],
             selector: {
                 app: "dashboard",
             },
             type: "NodePort",
         },
      },
       {
          apiVersion: "v1",
          kind: "Service",
          metadata: {
              labels: {
                  app: "dashboard-iad",
              },
              name: "dashboard-iad",
              namespace: "flowsnake",
          },
          spec: {
              ports: [
                  {
                      name: "tcp80",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9193,
                      nodePort: port_config.flowsnake.dashboard_iad,
                  },
              ],
              selector: {
                  app: "dashboard",
              },
              type: "NodePort",
          },
       },
       {
          apiVersion: "v1",
          kind: "Service",
          metadata: {
              labels: {
                  app: "dashboard-ia2",
              },
              name: "dashboard-ia2",
              namespace: "flowsnake",
          },
          spec: {
              ports: [
                  {
                      name: "tcp80",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9194,
                      nodePort: port_config.flowsnake.dashboard_ia2,
                  },
              ],
              selector: {
                  app: "dashboard",
              },
              type: "NodePort",
          },
       },
       {
          apiVersion: "v1",
          kind: "Service",
          metadata: {
              labels: {
                  app: "dashboard-ord",
              },
              name: "dashboard-ord",
              namespace: "flowsnake",
          },
          spec: {
              ports: [
                  {
                      name: "tcp80",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9195,
                      nodePort: port_config.flowsnake.dashboard_ord,
                  },
              ],
              selector: {
                  app: "dashboard",
              },
              type: "NodePort",
          },
       },
       {
          apiVersion: "v1",
          kind: "Service",
          metadata: {
              labels: {
                  app: "dashboard-par",
              },
              name: "dashboard-par",
              namespace: "flowsnake",
          },
          spec: {
              ports: [
                  {
                      name: "tcp80",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9196,
                      nodePort: port_config.flowsnake.dashboard_par,
                  },
              ],
              selector: {
                  app: "dashboard",
              },
              type: "NodePort",
          },
       },
       {
          apiVersion: "v1",
          kind: "Service",
          metadata: {
              labels: {
                  app: "dashboard-phx",
              },
              name: "dashboard-phx",
              namespace: "flowsnake",
          },
          spec: {
              ports: [
                  {
                      name: "tcp80",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9197,
                      nodePort: port_config.flowsnake.dashboard_phx,
                  },
              ],
              selector: {
                  app: "dashboard",
              },
              type: "NodePort",
          },
       },
       {
          apiVersion: "v1",
          kind: "Service",
          metadata: {
              labels: {
                  app: "dashboard-ph2",
              },
              name: "dashboard-ph2",
              namespace: "flowsnake",
          },
          spec: {
              ports: [
                  {
                      name: "tcp80",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9198,
                      nodePort: port_config.flowsnake.dashboard_ph2,
                  },
              ],
              selector: {
                  app: "dashboard",
              },
              type: "NodePort",
          },
       },
       {
          apiVersion: "v1",
          kind: "Service",
          metadata: {
              labels: {
                  app: "dashboard-ukb",
              },
              name: "dashboard-ukb",
              namespace: "flowsnake",
          },
          spec: {
              ports: [
                  {
                      name: "tcp80",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9199,
                      nodePort: port_config.flowsnake.dashboard_ukb,
                  },
              ],
              selector: {
                  app: "dashboard",
              },
              type: "NodePort",
          },
       },
       {
          apiVersion: "v1",
          kind: "Service",
          metadata: {
              labels: {
                  app: "dashboard-cdu",
              },
              name: "dashboard-cdu",
              namespace: "flowsnake",
          },
          spec: {
              ports: [
                  {
                      name: "tcp80",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9200,
                      nodePort: port_config.flowsnake.dashboard_cdu,
                  },
              ],
              selector: {
                  app: "dashboard",
              },
              type: "NodePort",
          },
       },
       {
          apiVersion: "v1",
          kind: "Service",
          metadata: {
              labels: {
                  app: "dashboard-syd",
              },
              name: "dashboard-syd",
              namespace: "flowsnake",
          },
          spec: {
              ports: [
                  {
                      name: "tcp80",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9201,
                      nodePort: port_config.flowsnake.dashboard_syd,
                  },
              ],
              selector: {
                  app: "dashboard",
              },
              type: "NodePort",
          },
       },
       {
          apiVersion: "v1",
          kind: "Service",
          metadata: {
              labels: {
                  app: "dashboard-yhu",
              },
              name: "dashboard-yhu",
              namespace: "flowsnake",
          },
          spec: {
              ports: [
                  {
                      name: "tcp80",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9202,
                      nodePort: port_config.flowsnake.dashboard_yhu,
                  },
              ],
              selector: {
                  app: "dashboard",
              },
              type: "NodePort",
          },
       },
       {
          apiVersion: "v1",
          kind: "Service",
          metadata: {
              labels: {
                  app: "dashboard-yul",
              },
              name: "dashboard-yul",
              namespace: "flowsnake",
          },
          spec: {
              ports: [
                  {
                      name: "tcp80",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9203,
                      nodePort: port_config.flowsnake.dashboard_yul,
                  },
              ],
              selector: {
                  app: "dashboard",
              },
              type: "NodePort",
          },
       },
       {
          apiVersion: "v1",
          kind: "Service",
          metadata: {
              labels: {
                  app: "dashboard-prd-data",
              },
              name: "dashboard-prd-data",
              namespace: "flowsnake",
          },
          spec: {
              ports: [
                  {
                      name: "tcp80",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9204,
                      nodePort: port_config.flowsnake.dashboard_prd_data,
                  },
              ],
              selector: {
                  app: "dashboard",
              },
              type: "NodePort",
          },
       },
       {
          apiVersion: "v1",
          kind: "Service",
          metadata: {
              labels: {
                  app: "dashboard-prd-dev",
              },
              name: "dashboard-prd-dev",
              namespace: "flowsnake",
          },
          spec: {
              ports: [
                  {
                      name: "tcp80",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9205,
                      nodePort: port_config.flowsnake.dashboard_prd_dev,
                  },
              ],
              selector: {
                  app: "dashboard",
              },
              type: "NodePort",
          },
       },
       {
          apiVersion: "v1",
          kind: "Service",
          metadata: {
              labels: {
                  app: "dashboard-prd-test",
              },
              name: "dashboard-prd-test",
              namespace: "flowsnake",
          },
          spec: {
              ports: [
                  {
                      name: "tcp80",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9206,
                      nodePort: port_config.flowsnake.dashboard_prd_test,
                  },
              ],
              selector: {
                  app: "dashboard",
              },
              type: "NodePort",
          },
       },
    ],
    kind: "List",
} else "SKIP"
