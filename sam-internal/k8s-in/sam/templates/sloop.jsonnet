local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
local mysql = import "sammysqlconfig.jsonnet";

if configs.estate == "prd-sam" then configs.deploymentBase("sam") {
    metadata+: {
        labels: {
            name: "sloop",
        } + configs.ownerLabel.sam,
        name: "sloop",
        namespace: "sam-system",
    },
    spec+: {
        replicas: 1,
        selector: {
            matchLabels: {
                name: "sloop",
            },
        },
        template: {
            metadata: {
                labels: {
                    name: "sloop",
                    apptype: "control",
                } + configs.ownerLabel.sam,
            },
            spec: {
                nodeSelector: {
                    pool: configs.estate,
                },
                containers: [
                    {
                        name: "sloop",
                        args: [
                            "-web-files-path=/webfiles/",
                            "--alsologtostderr",
                            "--ext-link1",
                            "Splunk=https://splunk-web.crz.salesforce.com/en-US/app/search/search?earliest=-60m&latest=now&q=search%20%60from_index_microapps%60%20%28kubernetes-container%3Anamespace%3D{{.Namespace}}%29%20%28rsyslog-base%3Adc%3Dprd%29%20%28kubernetes-container%3Apod%3D{{.Name}}%29%20%7C%20table%20_time%2C%20message%20%7C%20sort%20-%20_time;",
                            "--ext-link2",
                            "KubeDashboard=http://dashboard-prd-sam.csc-sam.prd-sam.prd.slb.sfdc.net/#!/pod/{{.Namespace}}/{{.Name}}?namespace={{.Namespace}}",
                            "--ext-link3",
                            "Deployment_ArgusAvailPct=https://argus-ui.data.sfdc.net/argus/#/viewmetrics?expression=-24h:sam.PRD.*.*sam*:deployment.AvailabilityPct%7BNamespace%2FDeploymentName%3D{{.Namespace}}%2F{{.Name}}%7D:avg:5m-avg",
                            "--ext-link4",
                            "Node_ArgusUptime=https://argus-ui.data.sfdc.net/argus/#/viewmetrics?expression=-24h:system.PRD.*.*sam*:uptime.uptime%7Bdevice%3D{{.Name}}%7D:avg:5m-avg",
                            "--ext-link5",
                            "Node_KubeletUptime=https://argus-ui.data.sfdc.net/argus/#/viewmetrics?expression=-24h:sam.watchdog.PRD.*.*sam*:age.kubelet%7Bdevice%3D{{.Name}}%7D:avg:5m-avg",
                        ],
                        command: [
                            "/bin/sloop",
                        ],
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/thargrove/sloop:thargrove-20190913_121940-b81f6f5",
                        volumeMounts: [
                            {
                                name: "sloop-data",
                                mountPath: "/data/",
                            },
                        ],
                        ports: [
                            {
                                containerPort: 8080,
                                protocol: "TCP",
                            },
                        ],
                    } + configs.ipAddressResourceRequest,
                    {
                        name: "prometheus",
                        args: [
                            "--config.file",
                            "/prometheusconfig/prometheus.json",
                        ],
                        image: samimages.prometheus,
                        volumeMounts: [
                            {
                                name: "prom-data",
                                mountPath: "/prometheus/",
                            },
                            {
                                name: "sloopconfig",
                                mountPath: "/prometheusconfig",
                            },
                        ],
                        ports: [
                            {
                                containerPort: 9090,
                                protocol: "TCP",
                            },
                        ],
                    },
                ],
                volumes: [
                    {
                        emptyDir: {
                            sizeLimit: "12Gi",
                        },
                        name: "sloop-data",
                    },
                    {
                        emptyDir: {
                            sizeLimit: "12Gi",
                        },
                        name: "prom-data",
                    },
                    {
                        configMap: {
                            name: "sloop",
                        },
                        name: "sloopconfig",
                    },
                ],
            } + configs.serviceAccount,
        },
    },
} else "SKIP"
