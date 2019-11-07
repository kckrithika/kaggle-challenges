local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then
{
   apiVersion: "apps/v1",
   kind: "Deployment",
   metadata: {
      annotations: {
         "manifestctl.sam.data.sfdc.net/swagger": "disable",
      },
      labels: {
         app: "istio-ingressgateway",
         slb-istio: "ingressgateway",
         release: "istio",
         owner: "slb",
      },
      name: "istio-ingressgateway",
      namespace: "slb",
   },
   spec: {
      replicas: 1,
      selector: {
         matchLabels: {
            app: "istio-ingressgateway",
            slb-istio: "ingressgateway",
         },
      },
      strategy: {
         rollingUpdate: {
            maxSurge: 1,
            maxUnavailable: 0,
         },
      },
      template: {
         metadata: {
            annotations: {
               "madkub.sam.sfdc.net/allcerts": "{\n \"certreqs\": [\n  {\n   \"cert-type\": \"client\",\n   \"kingdom\": \"prd\",\n   \"name\": \"tls-client-cert\",\n   \"role\": \"istio-ingressgateway.slb\"\n  },\n  {\n   \"cert-type\": \"server\",\n   \"kingdom\": \"prd\",\n   \"name\": \"tls-server-cert\",\n   \"role\": \"istio-ingressgateway.slb\",\n   \"san\": [\n    \"istio-ingressgateway\",\n    \"istio-ingressgateway.slb\",\n    \"istio-ingressgateway.slb.svc\",\n    \"istio-ingressgateway.slb.svc.prd-sam.prd.sam.sfdc.net\",\n    \"istio-ingressgateway.slb.prd-sam.prd.slb.sfdc.net\",\n    \"*.istio-prd.eng.sfdc.net\",\n    \"*.istiotest-prd.eng.sfdc.net\"\n   ]\n  }\n ]\n}",
               "sidecar.istio.io/inject": "false",
            },
            labels: {
               app: "istio-ingressgateway",
               chart: "gateways",
               heritage: "Tiller",
               slb-istio: "ingressgateway",
               name: "istio-ingressgateway",
               owner: "slb",
            },
         },
         spec: {
            affinity: {
               nodeAffinity: {
                  preferredDuringSchedulingIgnoredDuringExecution: [
                     {
                        preference: {
                           matchExpressions: [
                              {
                                 key: "beta.kubernetes.io/arch",
                                 operator: "In",
                                 values: [
                                    "amd64",
                                 ],
                              },
                           ],
                        },
                        weight: 2,
                     },
                     {
                        preference: {
                           matchExpressions: [
                              {
                                 key: "beta.kubernetes.io/arch",
                                 operator: "In",
                                 values: [
                                    "ppc64le",
                                 ],
                              },
                           ],
                        },
                        weight: 2,
                     },
                     {
                        preference: {
                           matchExpressions: [
                              {
                                 key: "beta.kubernetes.io/arch",
                                 operator: "In",
                                 values: [
                                    "s390x",
                                 ],
                              },
                           ],
                        },
                        weight: 2,
                     },
                  ],
                  requiredDuringSchedulingIgnoredDuringExecution: {
                     nodeSelectorTerms: [
                        {
                           matchExpressions: [
                              {
                                 key: "beta.kubernetes.io/arch",
                                 operator: "In",
                                 values: [
                                    "amd64",
                                    "ppc64le",
                                    "s390x",
                                 ],
                              },
                           ],
                        },
                     ],
                  },
               },
            },
            containers: [
               {
                  args: [
                     "proxy",
                     "router",
                     "--domain",
                     "$(POD_NAMESPACE).svc.cluster.local",
                     "--log_output_level",
                     "default:info",
                     "--drainDuration",
                     "45s",
                     "--parentShutdownDuration",
                     "1m0s",
                     "--connectTimeout",
                     "10s",
                     "--serviceCluster",
                     "istio-ingressgateway",
                     "--zipkinAddress",
                     "zipkin.service-mesh:9411",
                     "--envoyMetricsService",
                     "{\"address\":\"switchboard.service-mesh:15001\",\"tls_settings\":{\"mode\":2,\"client_certificate\":\"/client-certs/client/certificates/client.pem\",\"private_key\":\"/client-certs/client/keys/client-key.pem\",\"ca_certificates\":\"/client-certs/ca.pem\"},\"tcp_keepalive\":{\"probes\":3,\"time\":\"10s\",\"interval\":\"10s\"}}",
                     "--proxyAdminPort",
                     "15373",
                     "--statusPort",
                     "15020",
                     "--controlPlaneAuthPolicy",
                     "MUTUAL_TLS",
                     "--discoveryAddress",
                     "istio-pilot.mesh-control-plane:15011",
                     "--controlPlaneBootstrap=false",
                  ],
                  env: [
                     {
                        name: "ESTATE",
                        value: "prd-sp2-sam_coreapp",
                     },
                     {
                        name: "ISTIO_META_superpod",
                        value: "-",
                     },
                     {
                        name: "ISTIO_META_settings_path",
                        value: "istio.-.prd.-.istio-ingressgateway",
                     },
                     {
                        name: "ISTIO_META_hostname",
                        valueFrom: {
                           fieldRef: {
                              fieldPath: "metadata.name",
                           },
                        },
                     },
                     {
                        name: "ISTIO_META_namespace",
                        valueFrom: {
                           fieldRef: {
                              fieldPath: "metadata.namespace",
                           },
                        },
                     },
                     {
                        name: "ISTIO_METAJSON_METRICS_INCLUSIONS",
                        value: "{\"sidecar.istio.io/statsInclusionPrefixes\": \"access_log_file,cluster,cluster_manager,control_plane,http,http2,http_mixer_filter,listener,listener_manager,redis,runtime,server,stats,tcp,tcp_mixer_filter,tracing\"}",
                     },
                     {
                        name: "ISTIO_META_TLS_CLIENT_CERT_CHAIN",
                        value: "/client-certs/client/certificates/client.pem",
                     },
                     {
                        name: "ISTIO_META_TLS_CLIENT_KEY",
                        value: "/client-certs/client/keys/client-key.pem",
                     },
                     {
                        name: "ISTIO_META_TLS_CLIENT_ROOT_CERT",
                        value: "/client-certs/ca.pem",
                     },
                     {
                        name: "ISTIO_META_TLS_SERVER_CERT_CHAIN",
                        value: "/server-certs/server/certificates/server.pem",
                     },
                     {
                        name: "ISTIO_META_TLS_SERVER_KEY",
                        value: "/server-certs/server/keys/server-key.pem",
                     },
                     {
                        name: "ISTIO_META_TLS_SERVER_ROOT_CERT",
                        value: "/server-certs/ca.pem",
                     },
                     {
                        name: "ISTIO_META_kubernetes_cluster_name",
                        valueFrom: {
                           fieldRef: {
                              fieldPath: "metadata.labels['cluster']",
                           },
                        },
                     },
                     {
                        name: "NODE_NAME",
                        valueFrom: {
                           fieldRef: {
                              apiVersion: "v1",
                              fieldPath: "spec.nodeName",
                           },
                        },
                     },
                     {
                        name: "POD_NAME",
                        valueFrom: {
                           fieldRef: {
                              apiVersion: "v1",
                              fieldPath: "metadata.name",
                           },
                        },
                     },
                     {
                        name: "POD_NAMESPACE",
                        valueFrom: {
                           fieldRef: {
                              apiVersion: "v1",
                              fieldPath: "metadata.namespace",
                           },
                        },
                     },
                     {
                        name: "INSTANCE_IP",
                        valueFrom: {
                           fieldRef: {
                              apiVersion: "v1",
                              fieldPath: "status.podIP",
                           },
                        },
                     },
                     {
                        name: "HOST_IP",
                        valueFrom: {
                           fieldRef: {
                              apiVersion: "v1",
                              fieldPath: "status.hostIP",
                           },
                        },
                     },
                     {
                        name: "SERVICE_ACCOUNT",
                        valueFrom: {
                           fieldRef: {
                              fieldPath: "spec.serviceAccountName",
                           },
                        },
                     },
                     {
                        name: "ISTIO_META_POD_NAME",
                        valueFrom: {
                           fieldRef: {
                              apiVersion: "v1",
                              fieldPath: "metadata.name",
                           },
                        },
                     },
                     {
                        name: "ISTIO_META_CONFIG_NAMESPACE",
                        valueFrom: {
                           fieldRef: {
                              fieldPath: "metadata.namespace",
                           },
                        },
                     },
                     {
                        name: "ISTIO_METAJSON_LABELS",
                        value: "{\"app\":\"istio-ingressgateway\",\"chart\":\"gateways\",\"heritage\":\"Tiller\",\"istio\":\"ingressgateway\",\"release\":\"istio\"}\n",
                     },
                     {
                        name: "ISTIO_META_CLUSTER_ID",
                        value: "Kubernetes",
                     },
                     {
                        name: "SDS_ENABLED",
                        value: "false",
                     },
                     {
                        name: "ISTIO_META_WORKLOAD_NAME",
                        value: "istio-ingressgateway",
                     },
                     {
                        name: "ISTIO_META_OWNER",
                        value: "kubernetes://api/apps/v1/namespaces/mesh-control-plane/deployments/istio-ingressgateway",
                     },
                     {
                        name: "ISTIO_META_ROUTER_MODE",
                        value: "sni-dnat",
                     },
                  ],
                  image: "ops0-artifactrepo2-0-prd.data.sfdc.net/sfci/servicemesh/istio-packaging/proxy:abc19b71279da65c92ba35ed1f667fd3f8dc5ac9",
                  imagePullPolicy: "IfNotPresent",
                  name: "istio-proxy",
                  ports: [
                     {
                        containerPort: 8085,
                     },
                  ],
                  readinessProbe: {
                     failureThreshold: 30,
                     httpGet: {
                        path: "/healthz/ready",
                        port: 15020,
                        scheme: "HTTP",
                     },
                     initialDelaySeconds: 1,
                     periodSeconds: 2,
                     successThreshold: 1,
                     timeoutSeconds: 1,
                  },
                  resources: {
                     limits: {
                        cpu: "2000m",
                        memory: "1024Mi",
                     },
                     requests: {
                        cpu: "100m",
                        memory: "1024Mi",
                     },
                  },
                  securityContext: {
                     readOnlyRootFilesystem: true,
                     runAsUser: 1337,
                  },
                  volumeMounts: [
                     {
                        mountPath: "/client-certs",
                        name: "tls-client-cert",
                     },
                     {
                        mountPath: "/server-certs",
                        name: "tls-server-cert",
                     },
                     {
                        mountPath: "/etc/istio/proxy",
                        name: "istio-envoy",
                     },
                  ],
               },
               {
                  args: [
                     "/sam/madkub-client",
                     "--madkub-endpoint=https://10.254.208.254:32007",
                     "--maddog-endpoint=https://all.pkicontroller.pki.blank.prd.prod.non-estates.sfdcsd.net:8443",
                     "--maddog-server-ca=/maddog-certs/ca/security-ca.pem",
                     "--madkub-server-ca=/maddog-certs/ca/cacerts.pem",
                     "--cert-folders=tls-client-cert:/client-cert/",
                     "--cert-folders=tls-server-cert:/server-cert/",
                     "--token-folder=/tokens/",
                     "--ca-folder=/maddog-certs/ca",
                     "--refresher",
                     "--run-init-for-refresher-mode",
                  ],
                  env: [
                     {
                        name: "MADKUB_NODENAME",
                        valueFrom: {
                           fieldRef: {
                              apiVersion: "v1",
                              fieldPath: "spec.nodeName",
                           },
                        },
                     },
                     {
                        name: "MADKUB_NAME",
                        valueFrom: {
                           fieldRef: {
                              apiVersion: "v1",
                              fieldPath: "metadata.name",
                           },
                        },
                     },
                     {
                        name: "MADKUB_NAMESPACE",
                        valueFrom: {
                           fieldRef: {
                              apiVersion: "v1",
                              fieldPath: "metadata.namespace",
                           },
                        },
                     },
                     {
                        name: "ESTATE",
                        value: "prd-sp2-sam_coreapp",
                     },
                  ],
                  image: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/madkub:1.0.0-0000082-3d5c21b4",
                  imagePullPolicy: "IfNotPresent",
                  name: "madkub-refresher",
                  resources: {},
                  volumeMounts: [
                     {
                        mountPath: "/client-cert",
                        name: "tls-client-cert",
                     },
                     {
                        mountPath: "/server-cert",
                        name: "tls-server-cert",
                     },
                     {
                        mountPath: "/maddog-certs/",
                        name: "maddog-certs",
                     },
                     {
                        mountPath: "/tokens",
                        name: "tokens",
                     },
                  ],
               },
            ],
            initContainers: [
               {
                  args: [
                     "/sam/madkub-client",
                     "--madkub-endpoint=https://10.254.208.254:32007",
                     "--maddog-endpoint=https://all.pkicontroller.pki.blank.prd.prod.non-estates.sfdcsd.net:8443",
                     "--maddog-server-ca=/maddog-certs/ca/security-ca.pem",
                     "--madkub-server-ca=/maddog-certs/ca/cacerts.pem",
                     "--cert-folders=tls-client-cert:/client-cert/",
                     "--cert-folders=tls-server-cert:/server-cert/",
                     "--token-folder=/tokens/",
                     "--ca-folder=/maddog-certs/ca",
                  ],
                  env: [
                     {
                        name: "MADKUB_NODENAME",
                        valueFrom: {
                           fieldRef: {
                              apiVersion: "v1",
                              fieldPath: "spec.nodeName",
                           },
                        },
                     },
                     {
                        name: "MADKUB_NAME",
                        valueFrom: {
                           fieldRef: {
                              apiVersion: "v1",
                              fieldPath: "metadata.name",
                           },
                        },
                     },
                     {
                        name: "MADKUB_NAMESPACE",
                        valueFrom: {
                           fieldRef: {
                              apiVersion: "v1",
                              fieldPath: "metadata.namespace",
                           },
                        },
                     },
                  ],
                  image: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/madkub:1.0.0-0000082-3d5c21b4",
                  imagePullPolicy: "IfNotPresent",
                  name: "madkub-init",
                  volumeMounts: [
                     {
                        mountPath: "/client-cert",
                        name: "tls-client-cert",
                     },
                     {
                        mountPath: "/server-cert",
                        name: "tls-server-cert",
                     },
                     {
                        mountPath: "/maddog-certs/",
                        name: "maddog-certs",
                     },
                     {
                        mountPath: "/tokens",
                        name: "tokens",
                     },
                  ],
               },
               {
                  command: [
                     "bash",
                     "-c",
                     "set -ex\nchmod 775 -R /client-cert && chown -R 7447:7447 /client-cert\nchmod 775 -R /server-cert && chown -R 7447:7447 /server-cert\n",
                  ],
                  image: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/hypersam:sam-c07d4afb-673",
                  imagePullPolicy: "Always",
                  name: "permissionsetterinitcontainer",
                  securityContext: {
                     runAsNonRoot: false,
                     runAsUser: 0,
                  },
                  volumeMounts: [
                     {
                        mountPath: "/client-cert",
                        name: "tls-client-cert",
                     },
                     {
                        mountPath: "/server-cert",
                        name: "tls-server-cert",
                     },
                  ],
               },
            ],
            nodeSelector: {
               pool: "prd-slb",
            },
            serviceAccountName: "istio-ingressgateway-service-account",
            volumes: [
               {
                  hostPath: {
                     path: "/etc/pki_service",
                  },
                  name: "maddog-certs",
               },
               {
                  emptyDir: {
                     medium: "Memory",
                  },
                  name: "tls-client-cert",
               },
               {
                  emptyDir: {
                     medium: "Memory",
                  },
                  name: "tls-server-cert",
               },
               {
                  emptyDir: {
                     medium: "Memory",
                  },
                  name: "tokens",
               },
               {
                  emptyDir: {
                     medium: "Memory",
                  },
                  name: "istio-envoy",
               },
            ],
         },
      },
   },
} else "SKIP"
