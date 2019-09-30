local estate = std.extVar("estate");

if estate == "prd-dev-flowsnake_iot_test" then
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        "name": "dockerhbase-set",
        "namespace": "flowsnake-watchdog",
    },
    spec: {
        ports: [
            {
                name: "securedocker1",
                port: 60020,
                protocol: "TCP",
                targetPort: 60020
            },
            {
                name: "securedocker2",
                port: 9089,
                protocol: "TCP",
                targetPort: 9089
            },
            {
                name: "securedocker3",
                port: 9090,
                protocol: "TCP",
                targetPort: 9090
            },
            {
                name: "securedocker4",
                port: 9088,
                protocol: "TCP",
                targetPort: 9088
            },
            {
                name: "securedocker5",
                port: 15372,
                protocol: "TCP",
                targetPort: 15372
            },
            {
                name: "securedocker6",
                port: 60000,
                protocol: "TCP",
                targetPort: 60000
            },
            {
                name: "h-master",
                port: 60010,
                protocol: "TCP",
                targetPort: 60010
            },
            {
                name: "region-server",
                port: 60030,
                protocol: "TCP",
                targetPort: 60030
            },
            {
                name: "zookeeper",
                port: 2181,
                protocol: "TCP",
                targetPort: 2181
            },
            {
                name: "pqs-ssl",
                port: 8765,
                protocol: "TCP",
                targetPort: 8765
            },
            {
                name: "pqs-jdwp",
                port: 9005,
                protocol: "TCP",
                targetPort: 9005
            },
            {
                name: "hregion-server",
                port: 8071,
                protocol: "TCP",
                targetPort: 8071
            },
            {
                name: "resource-m",
                port: 8088,
                protocol: "TCP",
                targetPort: 8088
            },
            {
                name: "job-history",
                port: 19888,
                protocol: "TCP",
                targetPort: 19888
            },
            {
                name: "web-hdfs",
                port: 50070,
                protocol: "TCP",
                targetPort: 50070
            }
        ],
        selector: {
            "app": "dockerhbase"
        },
        type: "ClusterIP"
    }
}
{
   apiVersion: "v1",
   kind: "Service",
   metadata: {
      name: "dockerhbase-set",
      namespace: "flowsnake"
   },
   spec: {
      clusterIP: "None",
      ports: [
         {
            port: 60020,
            name: "securedocker1"
         },
         {
            port: 9089,
            name: "securedocker2"
         },
         {
            port: 9090,
            name: "securedocker3"
         },
         {
            port: 9088,
            name: "securedocker4"
         },
         {
            port: 15372,
            name: "securedocker5"
         },
         {
            port: 60000,
            name: "securedocker6"
         },
         {
            port: 60010,
            name: "h-master"
         },
         {
            port: 60030,
            name: "region-server"
         },
         {
            port: 2181,
            name: "zookeeper"
         },
         {
            port: 8765,
            name: "pqs-ssl"
         },
         {
            port: 9005,
            name: "pqs-jdwp"
         },
         {
            port: 8071,
            name: "hregion-server"
         },
         {
            port: 8088,
            name: "resource-m"
         },
         {
            port: 19888,
            name: "job-history"
         },
         {
            port: 50070,
            name: "web-hdfs"
         }
      ],
      selector: {
         app: "dockerhbase"
      }
   }
}
else
"SKIP"
