local configs = import "config.jsonnet";
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
            app: "dashboard",
        },
        name: "dashboard",
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
                        name: "dashboard-dfw",
                        # From https://git.soma.salesforce.com/dva-transformation/sam/tree/support-replication-controllers
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/dfw-flowsnake_prod",
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/dfw-flowsnake_prod/dashboard-webhook",
                            "--insecure-port=9190",
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: 9190,
                            hostPort: 9190,
                        }],
                    },
                    {
                        name: "dashboard-frf",
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/frf-flowsnake_prod",
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/frf-flowsnake_prod/dashboard-webhook",
                            "--insecure-port=9191",
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: 9191,
                            hostPort: 9191,
                        }],
                    },
                    {
                        name: "dashboard-hnd",
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/hnd-flowsnake_prod",
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/hnd-flowsnake_prod/dashboard-webhook",
                            "--insecure-port=9192",
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: 9192,
                            hostPort: 9192,
                        }],
                    },
                    {
                        name: "dashboard-iad",
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/iad-flowsnake_prod",
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/iad-flowsnake_prod/dashboard-webhook",
                            "--insecure-port=9193",
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: 9193,
                            hostPort: 9193,
                        }],
                    },
                    {
                        name: "dashboard-ia2",
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/ia2-flowsnake_prod",
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/ia2-flowsnake_prod/dashboard-webhook",
                            "--insecure-port=9194",
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: 9194,
                            hostPort: 9194,
                        }],
                    },
                    {
                        name: "dashboard-ord",
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/ord-flowsnake_prod",
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/ord-flowsnake_prod/dashboard-webhook",
                            "--insecure-port=9195",
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: 9195,
                            hostPort: 9195,
                        }],
                    },
                    {
                        name: "dashboard-par",
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/par-flowsnake_prod",
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/par-flowsnake_prod/dashboard-webhook",
                            "--insecure-port=9196",
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: 9196,
                            hostPort: 9196,
                        }],
                    },
                    {
                        name: "dashboard-phx",
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/phx-flowsnake_prod",
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/phx-flowsnake_prod/dashboard-webhook",
                            "--insecure-port=9197",
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: 9197,
                            hostPort: 9197,
                        }],
                    },
                    {
                        name: "dashboard-ph2",
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/ph2-flowsnake_prod",
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/ph2-flowsnake_prod/dashboard-webhook",
                            "--insecure-port=9198",
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: 9198,
                            hostPort: 9198,
                        }],
                    },
                    {
                        name: "dashboard-ukb",
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/ukb-flowsnake_prod",
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/ukb-flowsnake_prod/dashboard-webhook",
                            "--insecure-port=9199",
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: 9199,
                            hostPort: 9199,
                        }],
                    },
                    {
                        name: "dashboard-cdu",
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/cdu-flowsnake_prod",
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/cdu-flowsnake_prod/dashboard-webhook",
                            "--insecure-port=9200",
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: 9200,
                            hostPort: 9200,
                        }],
                    },
                    {
                        name: "dashboard-syd",
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/syd-flowsnake_prod",
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/syd-flowsnake_prod/dashboard-webhook",
                            "--insecure-port=9201",
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: 9201,
                            hostPort: 9201,
                        }],
                    },
                    {
                        name: "dashboard-yhu",
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/yhu-flowsnake_prod",
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/yhu-flowsnake_prod/dashboard-webhook",
                            "--insecure-port=9202",
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: 9202,
                            hostPort: 9202,
                        }],
                    },
                    {
                        name: "dashboard-yul",
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/yul-flowsnake_prod",
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/yul-flowsnake_prod/dashboard-webhook",
                            "--insecure-port=9203",
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: 9203,
                            hostPort: 9203,
                        }],
                    },
                    {
                        name: "dashboard-prd-data",
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/prd-data-flowsnake",
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/prd-data-flowsnake/dashboard-webhook",
                            "--insecure-port=9204",
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: 9204,
                            hostPort: 9204,
                        }],
                    },
                    {
                        name: "dashboard-prd-dev",
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/prd-dev-flowsnake_iot_test",
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/prd-dev-flowsnake_iot_test/dashboard-webhook",
                            "--insecure-port=9205",
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: 9205,
                            hostPort: 9205,
                        }],
                    },
                    {
                        name: "dashboard-prd-data-test",
                        image: flowsnake_images.dashboard,
                        args: commonArgs + [
                            "--apiserver-host=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/prd-data-flowsnake_test",
                            "--system-banner-webhook=http://pseudo-kubeapi.flowsnake.svc.cluster.local:40001/prd-data-flowsnake_test/dashboard-webhook",
                            "--insecure-port=9206",
                        ],
                        volumeMounts: volumeMounts,
                        ports: [{
                            containerPort: 9206,
                            hostPort: 9206,
                        }],
                    },
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
