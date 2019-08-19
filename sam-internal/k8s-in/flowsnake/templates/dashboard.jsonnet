local configs = import "config.jsonnet";
local portconfigs = import "flowsnake_hostports.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local estate = std.extVar("estate");

local volumeMounts = configs.filter_empty([
                       {
                           mountPath: "/tmp",
                           name: "temp",
                       },
                                   ]);
local commonArgs = ["--logtostderr=true"];

if estate == "prd-data-flowsnake" then ({
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            app: "k8s-dashboard",
        },
        name: "k8s-dashboard",
        namespace: "flowsnake",
    },
    spec: {
        replicas: 3,
        template: {
            metadata: {
                labels: {
                    app: "dashboard",
                },
                name: "dashboard",
                namespace: "flowsnake",
            },
            spec: {
                containers: [
                    {
                        name: item.name,
                        # From https://git.soma.salesforce.com/dva-transformation/sam/tree/support-replication-controllers
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/" + item.estate,
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/" + item.estate + "/dashboard-webhook",
                            "--insecure-port=" + item.port,
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: item.port,
                            hostPort: item.port,
                        }],
                    }
                    for item in [
                        { name: "dashboard-dfw", estate: "dfw-flowsnake_prod", port: portconfigs.dashboard_dfw },
                        { name: "dashboard-frf", estate: "frf-flowsnake_prod", port: portconfigs.dashboard_frf },
                        { name: "dashboard-hnd", estate: "hnd-flowsnake_prod", port: portconfigs.dashboard_hnd },
                        { name: "dashboard-iad", estate: "iad-flowsnake_prod", port: portconfigs.dashboard_iad },
                        { name: "dashboard-ia2", estate: "ia2-flowsnake_prod", port: portconfigs.dashboard_ia2 },
                        { name: "dashboard-ord", estate: "ord-flowsnake_prod", port: portconfigs.dashboard_ord },
                        { name: "dashboard-par", estate: "par-flowsnake_prod", port: portconfigs.dashboard_par },
                        { name: "dashboard-phx", estate: "phx-flowsnake_prod", port: portconfigs.dashboard_phx },
                        { name: "dashboard-ph2", estate: "ph2-flowsnake_prod", port: portconfigs.dashboard_ph2 },
                        { name: "dashboard-ukb", estate: "ukb-flowsnake_prod", port: portconfigs.dashboard_ukb },
                        { name: "dashboard-cdu", estate: "cdu-flowsnake_prod", port: portconfigs.dashboard_cdu },
                        { name: "dashboard-syd", estate: "syd-flowsnake_prod", port: portconfigs.dashboard_syd },
                        { name: "dashboard-yhu", estate: "yhu-flowsnake_prod", port: portconfigs.dashboard_yhu },
                        { name: "dashboard-yul", estate: "yul-flowsnake_prod", port: portconfigs.dashboard_yul },
                        { name: "dashboard-prd-data", estate: "prd-data-flowsnake", port: portconfigs.dashboard_prd_data },
                        { name: "dashboard-prd-dev", estate: "prd-dev-flowsnake_iot_test", port: portconfigs.dashboard_prd_dev },
                        { name: "dashboard-prd-data-test", estate: "prd-data-flowsnake_test", port: portconfigs.dashboard_prd_test },
                    ]
                ],
                volumes: configs.filter_empty([
                    {
                        emptyDir: {},
                        name: "temp",
                    },
                ]),
            },
        },
    },
}) else "SKIP"
