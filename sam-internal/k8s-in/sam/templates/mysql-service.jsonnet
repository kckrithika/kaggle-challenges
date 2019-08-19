local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "prd-samtwo" || configs.estate == "prd-data-flowsnake" then
{
    apiVersion: "v1",
    items: [
        {
            apiVersion: "v1",
            kind: "Service",
            metadata: {
                annotations: {
                    "slb.sfdc.net/name": "mysql-inmem-read",
                    "slb.sfdc.net/portconfigurations": "[{\"lbtype\": \"\", \"nodeport\": 0, \"port\": 3306, \"reencrypt\": false, \"sticky\": 1, \"targetport\": 3306}]",
                },
                creationTimestamp: "2018-09-21T22:32:11Z",
                labels: {
                    app: "mysql-pure-cache",
                },
                name: if configs.estate == "prd-data-flowsnake" then "mysql" else "mysql-inmem-read",
                namespace: if configs.estate == "prd-data-flowsnake" then "flowsnake" else "sam-system",
            },
            spec: {
                ports: [
                    {
                        name: "mysql",
                        port: 3306,
                        protocol: "TCP",
                        targetPort: 3306,
                    },
                ],
                selector: {
                    app: "mysql-pure-cache",
                },
                sessionAffinity: "None",
                type: "ClusterIP",
            },
            status: {
                loadBalancer: {},
            },
        },
        {
            apiVersion: "v1",
            kind: "Service",
            metadata: {
                annotations: {
                    "slb.sfdc.net/name": "mysql-inmem-service",
                    "slb.sfdc.net/portconfigurations": "[{\"lbtype\": \"\", \"nodeport\": 0, \"port\": 3306, \"reencrypt\": false, \"sticky\": 1, \"targetport\": 3306}]",
                },
                labels: {
                    app: "mysql-pure-cache",
                    sam_app: "mysql-pure-cache",
                    sam_function: "mysql-pure-cache",
                    sam_loadbalancer: "mysql-pure-cache",
                },
                name: if configs.estate == "prd-data-flowsnake" then "mysql-service" else "mysql-inmem-service",
                namespace: if configs.estate == "prd-data-flowsnake" then "flowsnake" else "sam-system",
            },
            spec: {
                clusterIP: "None",
                ports: [
                    {
                        name: "mysql",
                        port: 3306,
                        protocol: "TCP",
                        targetPort: 3306,
                    },
                ],
                selector: {
                    app: "mysql-pure-cache",
                    sam_app: "mysql-pure-cache",
                    sam_function: "mysql-pure-cache",
                },
                sessionAffinity: "None",
                type: "ClusterIP",
            },
        },
    ],
    kind: "List",
} else "SKIP"
