local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local samimages = import "sam/samimages.jsonnet";

if configs.kingdom == "prd" && configs.estate == "prd-sdc" then {
     apiVersion: "extensions/v1beta1",
     kind: "Deployment",
     metadata: {
      creationTimestamp: null,
      name: "slb-nginx-proxy",
      namespace: "sam-system",
      labels: {
        name: "slb-nginx-proxy",
      },
     },
     spec: {
      minReadySeconds: 30,
      replicas: 2,
      strategy: {
       type: "RollingUpdate",
      },
      template: {
       metadata: {
        labels: {
          name: "slb-nginx-proxy",
        },
        namespace: "sam-system",
        annotations: {
         "madkub.sam.sfdc.net/allcerts": "{
            \"certreqs\":[
                {
                    \"name\": \"cert1\",
                    \"san\":[
                        \"*.slb.sfdc.net\",
                        \"*.sam-system.slb.sfdc.net\"
                    ],
                    \"cert-type\":\"server\",
                    \"kingdom\":\"prd\",
                    \"role\": \"sam_compute\"
                },
                {
                    \"name\": \"cert2\",
                    \"cert-type\":\"client\",
                    \"kingdom\":\"prd\",
                    \"role\": \"sam_compute\"
                }
            ]
         }",
         "pod.beta.kubernetes.io/init-containers": "[
            {
              \"image\": \"" + samimages.madkub + "\",
              \"args\": [
                \"/sam/madkub-client\",
                \"--madkub-endpoint\",
                \"https://$(MADKUBSERVER_SERVICE_HOST):32007\",
                \"--maddog-endpoint\",
                \"https://all.pkicontroller.pki.blank.prd.prod.non-estates.sfdcsd.net:8443\",
                \"--maddog-server-ca\",
                \"/maddog-certs/ca/security-ca.pem\",
                \"--madkub-server-ca\",
                \"/maddog-certs/ca/cacerts.pem\",
                \"--cert-folders\",
                \"cert1:/cert1/\",
                \"--cert-folders\",
                \"cert2:/cert2/\",
                \"--token-folder\",
                \"/tokens/\",
                \"--requested-cert-type\",
                \"client\"
              ],
              \"name\": \"madkub-init\",
              \"imagePullPolicy\": \"IfNotPresent\",
              \"volumeMounts\": [
                {
                    \"mountPath\": \"/cert1\",
                    \"name\": \"cert1\"
                },
                {
                    \"mountPath\": \"/cert2\",
                    \"name\": \"cert2\"
                },
                {
                    \"mountPath\": \"/maddog-certs/\",
                    \"name\": \"maddog-certs\"
                },
                {
                    \"mountPath\": \"/tokens\",
                    \"name\": \"tokens\"
                }
              ],
              \"env\": [
                {
                    \"name\": \"MADKUB_NODENAME\",
                    \"valueFrom\":
                    {
                        \"fieldRef\":{\"fieldPath\": \"spec.nodeName\", \"apiVersion\": \"v1\"}
                    }
                },
                {
                    \"name\": \"MADKUB_NAME\",
                    \"valueFrom\":
                    {
                        \"fieldRef\":{\"fieldPath\": \"metadata.name\", \"apiVersion\": \"v1\"}
                    }
                },
                {
                    \"name\": \"MADKUB_NAMESPACE\",
                    \"valueFrom\":
                    {
                        \"fieldRef\":{\"fieldPath\": \"metadata.namespace\", \"apiVersion\": \"v1\"}
                    }
                }
              ]
            }
         ]",
        },
        creationTimestamp: null,
       },
       spec: {
        containers: [
         {
            name: "slb-nginx-proxy",
            image: slbimages.slbnginx,
            command: ["/runner.sh"],
            livenessProbe: {
                httpGet: {
                    path: "/",
                    port: portconfigs.slb.slbNginxProxyLivenessProbePort,
                },
                initialDelaySeconds: 15,
                periodSeconds: 10,
            },
            volumeMounts: configs.filter_empty([
               {
                    name: "var-target-config-volume",
                    mountPath: "/etc/nginx/conf.d",
               },
               slbconfigs.logs_volume_mount,
               {
                mountPath: "/cert1",
                name: "cert1",
               },
               {
                mountPath: "/cert2",
                name: "cert2",
               },
            ]),
         },
         {
            name: "slb-file-watcher",
            image: slbimages.hypersdn,
            command: [
                "/sdn/slb-file-watcher",
                "--filePath=/host/data/slb/logs/slb-nginx-proxy.emerg.log",
                "--metricName=nginx-emergency",
                "--lastModReportTime=120s",
                "--scanPeriod=10s",
                "--skipZeroLengthFiles=true",
                "--metricsEndpoint=" + configs.funnelVIP,
                "--log_dir=" + slbconfigs.logsDir,
            ],
            volumeMounts: configs.filter_empty([
                {
                    name: "var-target-config-volume",
                    mountPath: "/etc/nginx/conf.d",
                },
                slbconfigs.logs_volume_mount,
            ]),
         },
         {
          args: [
           "/sam/madkub-client",
           "--madkub-endpoint",
           "https://$(MADKUBSERVER_SERVICE_HOST):32007",
           "--maddog-endpoint",
           "https://all.pkicontroller.pki.blank.prd.prod.non-estates.sfdcsd.net:8443",
           "--maddog-server-ca",
           "/maddog-certs/ca/security-ca.pem",
           "--madkub-server-ca",
           "/maddog-certs/ca/cacerts.pem",
           "--cert-folders",
           "cert1:/cert1/",
           "--cert-folders",
           "cert2:/cert2/",
           "--token-folder",
           "/tokens/",
           "--requested-cert-type",
           "client",
           "--refresher",
          ],
          env: [
           {
            name: "MADKUB_NODENAME",
            valueFrom: {
             fieldRef: {
              fieldPath: "spec.nodeName",
             },
            },
           },
           {
            name: "MADKUB_NAME",
            valueFrom: {
             fieldRef: {
              fieldPath: "metadata.name",
             },
            },
           },
           {
            name: "MADKUB_NAMESPACE",
            valueFrom: {
             fieldRef: {
              fieldPath: "metadata.namespace",
             },
            },
           },
          ],
          image: samimages.madkub,
          name: "madkub-refresher",
          resources: {},
          volumeMounts: [
           {
            mountPath: "/cert1",
            name: "cert1",
           },
           {
            mountPath: "/cert2",
            name: "cert2",
           },
           {
            mountPath: "/tokens",
            name: "tokens",
           },
           {
            mountPath: "/maddog-certs/",
            name: "maddog-certs",
           },
          ],
         },
        ],
        hostNetwork: true,
        nodeSelector: {
            "slb-service": "slb-nginx",
        },
        restartPolicy: "Always",
        volumes: configs.filter_empty([
         slbconfigs.logs_volume,
         {
           name: "var-target-config-volume",
           hostPath: {
               path: slbconfigs.slbDockerDir + "/nginx/config",
            },
         },
         {
          emptyDir: {
           medium: "Memory",
          },
          name: "cert1",
         },
         {
          emptyDir: {
           medium: "Memory",
          },
          name: "cert2",
         },
         {
          emptyDir: {
           medium: "Memory",
          },
          name: "tokens",
         },
         {
          hostPath: {
           path: "/etc/pki_service",
          },
          name: "maddog-certs",
         },
        ]),
       },
      },
     },
} else if configs.kingdom == "prd" && configs.estate != "prd-sdc" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-nginx-proxy",
        },
        name: "slb-nginx-proxy",
        namespace: "sam-system",
    },
    spec: {
        replicas: if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then 1 else 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-nginx-proxy",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                     {
                        name: "var-target-config-volume",
                        hostPath: {
                            path: slbconfigs.slbDockerDir + "/nginx/config",
                         },
                     },
                     slbconfigs.logs_volume,
                ]),
                containers: [
                    {
                        name: "slb-nginx-proxy",
                        image: slbimages.slbnginx,
                        command: ["/runner.sh"],
                        livenessProbe: {
                        httpGet: {
                            path: "/",
                            port: portconfigs.slb.slbNginxProxyLivenessProbePort,
                        },
                        initialDelaySeconds: 15,
                        periodSeconds: 10,
                        },
                        volumeMounts: configs.filter_empty([
                        {
                            name: "var-target-config-volume",
                            mountPath: "/etc/nginx/conf.d",
                        },
                        slbconfigs.logs_volume_mount,
                        ]),
                    },
                {
                    name: "slb-file-watcher",
                    image: slbimages.hypersdn,
                    command: [
                        "/sdn/slb-file-watcher",
                        "--filePath=/host/data/slb/logs/slb-nginx-proxy.emerg.log",
                        "--metricName=nginx-emergency",
                        "--lastModReportTime=120s",
                        "--scanPeriod=10s",
                        "--skipZeroLengthFiles=true",
                        "--metricsEndpoint=" + configs.funnelVIP,
                        "--log_dir=" + slbconfigs.logsDir,
                    ],
                volumeMounts: configs.filter_empty([
                    {
                        name: "var-target-config-volume",
                        mountPath: "/etc/nginx/conf.d",
                    },
                    slbconfigs.logs_volume_mount,
                ]),
                },
                ],

                nodeSelector: {
                    "slb-service": "slb-nginx",
                },
            },
        },
    },
} else "SKIP"
