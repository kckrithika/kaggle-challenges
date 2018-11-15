local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then
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
                    app: "mysql-inmem",
                },
                name: "mysql-inmem-read",
                namespace: "sam-system",
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
                    app: "mysql-inmem",
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
                    app: "mysql-inmem",
                    sam_app: "mysql-inmem",
                    sam_function: "mysql-inmem",
                    sam_loadbalancer: "mysql-inmem",
                },
                name: "mysql-inmem-service",
                namespace: "sam-system",
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
                    app: "mysql-inmem",
                    sam_app: "mysql-inmem",
                    sam_function: "mysql-inmem",
                },
                sessionAffinity: "None",
                type: "ClusterIP",
            },
        },
    ],
    kind: "List",
} else "SKIP"
