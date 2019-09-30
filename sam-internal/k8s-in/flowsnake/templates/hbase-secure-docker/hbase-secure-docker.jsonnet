local estate = std.extVar("estate");

if estate == "prd-dev-flowsnake_iot_test" then
{
   apiVersion: "apps/v1beta1",
   kind: "StatefulSet",
   metadata: {
      labels: {
         name: "dockerhbase"
      },
      name: "dockerhbase",
      namespace: "flowsnake-watchdog"
   },
   spec: {
      replicas: 1,
      serviceName: "dockerhbase-set",
      template: {
         metadata: {
            labels: {
               app: "dockerhbase",
               name: "dockerhbase"
            }
         },
         spec: {
            containers: [
               {
                  command: [
                       "/bin/bash",
                       "-c",
                       "cat /etc/hosts; cat /tmp/hosts1; echo 1; sudo chmod ugoa+rwx /etc/hosts; cat /etc/hosts; cat /tmp/hosts1; echo 2; sed 's/dockerhbase-0.dockerhbase-set.flowsnake.svc.cluster.local. dockerhbase-0/dockerhbase1-mnds1-1-sfm.ops.sfdc.net /g' /etc/hosts \u003e /tmp/hosts1; cat /etc/hosts; cat /tmp/hosts1; echo 3;sed 's/localhost/dockerhbase1-mnds1-1-sfm.ops.sfdc.net localhost/g' /tmp/hosts1 \u003e /tmp/hosts2; cat /etc/hosts; cat /tmp/hosts1; cat /tmp/hosts2; echo 4;  echo '10.253.229.26 hbase-release1-1-sfm.ops.sfdc.net' \u003e\u003e /tmp/hosts2 ; cat /tmp/hosts2 echo 5; cp /tmp/hosts2 /etc/hosts; cat /etc/hosts; cat /tmp/hosts2 ; echo 'Modifying instance.xml phoenix version' ; sudo chmod ugoa+rwx /home/sfdc/current/bigdata-conf/conf/util/instances/local_secure-docker_dev_dockerk8hbase1.xml ; grep 4.13 /home/sfdc/current/bigdata-conf/conf/util/instances/local_secure-docker_dev_dockerk8hbase1.xml ; sed -i 's/4.13.0/4.14.1/g' /deploy/k8/local_secure-docker_dev_dockerk8hbase1.xml ; grep 4.14 /deploy/k8/local_secure-docker_dev_dockerk8hbase1.xml ; echo 'Modifying hbase site.xml for binding' ; sudo chmod ugoa+rwx /home/sfdc/current/bigdata-conf/conf/hbase/hbase-site.xml ; sed -i.bkp ' s/\u003c\\/configuration\u003e/\u003cproperty\u003e\u003cname\u003ehbase\\.master\\.ipc\\.address\u003c\\/name\u003e\u003cvalue\u003e0\\.0\\.0\\.0\u003c\\/value\u003e\u003c\\/property\u003e\u003cproperty\u003e\u003cname\u003ehbase\\.regionserver\\.ipc\\.address\u003c\\/name\u003e\u003cvalue\u003e0\\.0\\.0\\.0\u003c\\/value\u003e\u003c\\/property\u003e\u003c\\/configuration\u003e/g' /home/sfdc/current/bigdata-conf/conf/hbase/hbase-site.xml ; echo 'Running startup /deploy/startup.sh' ; /deploy/startup.sh"
                  ],
                  env: [
                     {
                        name: "HOSTNAME",
                        value: "dockerhbase-0"
                     },
                     {
                        name: "SECURITY",
                        value: "enable"
                     }
                  ],
                  image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/jinxing.wang/hbase_k8_dev:w01",
                  imagePullPolicy: "IfNotPresent",
                  name: "dockerhbase",
                  securityContext: {
                     capabilities: {
                        add: [
                           "all"
                        ]
                     }
                  },
                  ports: [
                     {
                        containerPort: 60020,
                        name: "securedocker1"
                     },
                     {
                        containerPort: 9089,
                        name: "securedocker2"
                     },
                     {
                        containerPort: 9090,
                        name: "securedocker3"
                     },
                     {
                        containerPort: 9088,
                        name: "securedocker4"
                     },
                     {
                        containerPort: 15372,
                        name: "securedocker5"
                     },
                     {
                        containerPort: 60000,
                        name: "securedocker6"
                     },
                     {
                        containerPort: 60010,
                        name: "h-master"
                     },
                     {
                        containerPort: 60030,
                        name: "region-server"
                     },
                     {
                        containerPort: 2181,
                        name: "zookeeper"
                     },
                     {
                        containerPort: 8765,
                        name: "pqs-ssl"
                     },
                     {
                        containerPort: 9005,
                        name: "pqs-jdwp"
                     },
                     {
                        containerPort: 8071,
                        name: "hregion-server"
                     },
                     {
                        containerPort: 8088,
                        name: "resource-m"
                     },
                     {
                        containerPort: 19888,
                        name: "job-history"
                     },
                     {
                        containerPort: 50070,
                        name: "web-hdfs"
                     }
                  ]
               }
            ]
         }
      }
   }
}
else
"SKIP"
