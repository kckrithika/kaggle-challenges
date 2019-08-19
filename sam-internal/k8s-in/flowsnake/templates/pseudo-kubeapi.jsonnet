local configs = import "config.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local estate = std.extVar("estate");

if estate == "prd-data-flowsnake" then ({
    local label_node = self.spec.template.metadata.labels,
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "pseudo-kubeapi",
        },
        name: "pseudo-kubeapi",
        namespace: "flowsnake",
    },
    spec: {
        replicas: 5,
        selector: {
            matchLabels: {
                name: label_node.name,
                apptype: label_node.apptype,
            },
        },
        template: {
            metadata: {
                labels: {
                    apptype: "control",
                    name: "pseudo-kubeapi",
                    app: "pseudo-kubeapi",
                },
                namespace: "flowsnake",
            },
            spec: {
                containers: [{
                    name: "virtual-api",
                    image: flowsnake_images.pseudo_kubeapi,
                    command: [
                        "/sam/virtual-api",
                        "--sql-db-host=mysql-service.flowsnake.svc.cluster.local",
                        "--sql-db-port=3306",
                        "--sql-db-name=sam_kube_resource",
                        "--sql-db-pass-file=/var/secrets/pseudo-api",
                        "--sql-db-user=pseudo-api",
                        "--sql-db-resources-table=k8s_resource",
                        "--v=4",
                        "--alsologtostderr",
                        "--insecure-port=7002",
                        "--passthrough-api-server=k8sproxy.sam-system.prd-sam.prd.slb.sfdc.net:5000",
                        "--passthrough-all-cluster=flowsnake",
                        "--secret-passthrough-namespace=kube-system",
                    ],
                    volumeMounts: configs.filter_empty([
                        {
                            mountPath: "/var/secrets",
                            name: "mysql-passwords",
                            readOnly: true,
                        },
                    ]),
                }],
                volumes: configs.filter_empty([
                    {
                        secret: {
                            defaultMode: 420,
                            secretName: "mysql-passwords",
                        },
                        name: "mysql-passwords",
                    },
                ]),
            },
        },
    },
}) else "SKIP"
