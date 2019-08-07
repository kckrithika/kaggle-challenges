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
                  app: item.name,
              },
              name: item.name,
              namespace: "flowsnake",
          },
          spec: {
              ports: [
                  {
                      name: "tcp80",
                      port: 80,
                      protocol: "TCP",
                      targetPort: item.targetPort,
                      nodePort: item.nodePort,
                  },
              ],
              selector: {
                  app: "dashboard",
              },
              type: "NodePort",
          },
       }
        for item in [
            { name: "dashboard-dfw", targetPort: 9190, nodePort: port_config.flowsnake.dashboard_dfw },
            { name: "dashboard-frf", targetPort: 9191, nodePort: port_config.flowsnake.dashboard_frf },
            { name: "dashboard-hnd", targetPort: 9192, nodePort: port_config.flowsnake.dashboard_hnd },
            { name: "dashboard-iad", targetPort: 9193, nodePort: port_config.flowsnake.dashboard_iad },
            { name: "dashboard-ia2", targetPort: 9194, nodePort: port_config.flowsnake.dashboard_ia2 },
            { name: "dashboard-ord", targetPort: 9195, nodePort: port_config.flowsnake.dashboard_ord },
            { name: "dashboard-par", targetPort: 9196, nodePort: port_config.flowsnake.dashboard_par },
            { name: "dashboard-phx", targetPort: 9197, nodePort: port_config.flowsnake.dashboard_phx },
            { name: "dashboard-ph2", targetPort: 9198, nodePort: port_config.flowsnake.dashboard_ph2 },
            { name: "dashboard-ukb", targetPort: 9199, nodePort: port_config.flowsnake.dashboard_ukb },
            { name: "dashboard-cdu", targetPort: 9200, nodePort: port_config.flowsnake.dashboard_cdu },
            { name: "dashboard-syd", targetPort: 9201, nodePort: port_config.flowsnake.dashboard_syd },
            { name: "dashboard-yhu", targetPort: 9202, nodePort: port_config.flowsnake.dashboard_yhu },
            { name: "dashboard-yul", targetPort: 9203, nodePort: port_config.flowsnake.dashboard_yul },
            { name: "dashboard-prd-data", targetPort: 9204, nodePort: port_config.flowsnake.dashboard_prd_data },
            { name: "dashboard-prd-dev", targetPort: 9205, nodePort: port_config.flowsnake.dashboard_prd_dev },
            { name: "dashboard-prd-test", targetPort: 9206, nodePort: port_config.flowsnake.dashboard_prd_test },
        ]
    ],
    kind: "List",
} else "SKIP"
