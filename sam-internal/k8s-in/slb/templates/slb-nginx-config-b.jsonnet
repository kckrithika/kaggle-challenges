local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };

if configs.estate == "prd-sdc" || configs.estate == "prd-samtest" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-nginx-config-b",
        },
        name: "slb-nginx-config-b",
        namespace: "sam-system",
    },
    spec: {
        replicas: if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then 1 else 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-nginx-config-b",
                },
                namespace: "sam-system",
                annotations: {
                         "madkub.sam.sfdc.net/allcerts": "{
                            \"certreqs\":[
                                {
                                    \"name\": \"cert1\",
                                    \"cert-type\":\"server\",
                                    \"kingdom\":\"prd\",
                                    \"role\": \"sam_compute\",
                                    \"san\":[
                                        \"*.sam-system." + configs.estate + ".prd.slb.sfdc.net\"
                                    ]
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
                     slbconfigs.slb_config_volume,
                     slbconfigs.logs_volume,
                     configs.sfdchosts_volume,
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
                containers: [
                    {
                        ports: [
                             {
                                name: "slb-nginx-port",
                                containerPort: portconfigs.slb.slbNginxControlPort,
                             },
                        ],
                        name: "slb-nginx-config-b",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-nginx-config",
                            "--configDir=" + slbconfigs.configDir,
                            "--target=" + slbconfigs.slbDir + "/nginx/config",
                            "--netInterfaceName=eth0",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                            "--maxDeleteServiceCount=3",
                            "--httpsEnabled="
                            + "slb-canary-proxy-http.sam-system." + configs.estate + ".prd.slb.sfdc.net,slb-portal-service.sam-system." + configs.estate + ".prd.slb.sfdc.net",
                            configs.sfdchosts_arg,
                        ],
                        volumeMounts: configs.filter_empty([
                            {
                                name: "var-target-config-volume",
                                mountPath: slbconfigs.slbDir + "/nginx/config",
                            },
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                        },
                   },
                   {
                               name: "slb-nginx-proxy-b",
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
                                   configs.sfdchosts_arg,
                               ],
                               volumeMounts: configs.filter_empty([
                                   {
                                       name: "var-target-config-volume",
                                       mountPath: "/etc/nginx/conf.d",
                                   },
                                   slbconfigs.logs_volume_mount,
                                   configs.sfdchosts_volume_mount,
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

                nodeSelector: {
                    "slb-service": "slb-nginx-b",
                },
            },
        },
    },
} else if configs.kingdom == "prd" then {
  apiVersion: "extensions/v1beta1",
      kind: "Deployment",
      metadata: {
          labels: {
              name: "slb-nginx-config-b",
          },
          name: "slb-nginx-config-b",
          namespace: "sam-system",
      },
      spec: {
          replicas: if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then 1 else 2,
          template: {
              metadata: {
                  labels: {
                      name: "slb-nginx-config-b",
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
                       slbconfigs.slb_config_volume,
                       slbconfigs.logs_volume,
                       configs.sfdchosts_volume,
                  ]),
                  containers: [
                      {
                          ports: [
                               {
                                  name: "slb-nginx-port",
                                  containerPort: portconfigs.slb.slbNginxControlPort,
                               },
                          ],
                          name: "slb-nginx-config-b",
                          image: slbimages.hypersdn,
                          command: [
                              "/sdn/slb-nginx-config",
                              "--configDir=" + slbconfigs.configDir,
                              "--target=" + slbconfigs.slbDir + "/nginx/config",
                              "--netInterfaceName=eth0",
                              "--metricsEndpoint=" + configs.funnelVIP,
                              "--log_dir=" + slbconfigs.logsDir,
                              "--maxDeleteServiceCount=3",
                              "--httpsEnabled="
                              + "slb-canary-proxy-http.sam-system." + configs.estate + ".prd.slb.sfdc.net,slb-portal-service.sam-system." + configs.estate + ".prd.slb.sfdc.net",
                              configs.sfdchosts_arg,
                          ],
                          volumeMounts: configs.filter_empty([
                              {
                                  name: "var-target-config-volume",
                                  mountPath: slbconfigs.slbDir + "/nginx/config",
                              },
                              slbconfigs.slb_config_volume_mount,
                              slbconfigs.logs_volume_mount,
                              configs.sfdchosts_volume_mount,
                          ]),
                          securityContext: {
                              privileged: true,
                          },
                     },
                      {
                                               name: "slb-nginx-proxy-b",
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
                                               configs.sfdchosts_arg,
                                           ],
                                       volumeMounts: configs.filter_empty([
                                           {
                                               name: "var-target-config-volume",
                                               mountPath: "/etc/nginx/conf.d",
                                           },
                                           slbconfigs.logs_volume_mount,
                                           configs.sfdchosts_volume_mount,
                                       ]),
                                       },
                     ],

                  nodeSelector: {
                      "slb-service": "slb-nginx-b",
                  },
              },
          },
      },
} else "SKIP"
