local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then
{
  apiVersion: "extensions/v1beta1",
  kind: "Deployment",
  metadata: {
    creationTimestamp: null,
    name: "ordering-istio",
    namespace: "service-mesh",
  },
  spec: {
    replicas: 1,
    strategy: {
    },
    template: {
      metadata: {
        annotations: {
          "sidecar.istio.io/status": "{\"version\":\"72c62d4fd573294d59a05ccbf9b25cd5627245f130b078c00d2b1f213d98da51\",\"initContainers\":[\"istio-init\"],\"containers\":[\"istio-proxy\"],\"volumes\":[\"istio-envoy\",\"istio-certs\"],\"imagePullSecrets\":null}",
        },
        creationTimestamp: null,
        labels: {
          app: "ordering-istio",
          version: "v1",
        },
      },
      spec: {
        nodeSelector: {
          master: "true",
        },
        containers: [
          {
            env: [
              {
                name: "SCONE_SHIPPING_DEST",
                value: "shipping.service-mesh:7020",
              },
            ],
            image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/sfci/servicelibs/scone-ms-examples/scone-ordering:86a47e93cb4796e4a24f63cee4b305356ddecc1e",
            imagePullPolicy: "IfNotPresent",
            name: "ordering",
            ports: [
              {
                containerPort: 7021,
              },
            ],
            resources: {
            },
          },
          {
            args: [
              "proxy",
              "sidecar",
              "--configPath",
              "/etc/istio/proxy",
              "--binaryPath",
              "/usr/local/bin/envoy",
              "--serviceCluster",
              "ordering-istio",
              "--drainDuration",
              "45s",
              "--parentShutdownDuration",
              "1m0s",
              "--discoveryAddress",
              "istio-pilot.service-mesh:15010",
              "--discoveryRefreshDelay",
              "1s",
              "--zipkinAddress",
              "zipkin.istio-system:9411",
              "--connectTimeout",
              "10s",
              "--proxyAdminPort",
              "15000",
              "--controlPlaneAuthPolicy",
              "NONE",
            ],
            env: [
              {
                name: "POD_NAME",
                valueFrom: {
                  fieldRef: {
                    fieldPath: "metadata.name",
                  },
                },
              },
              {
                name: "POD_NAMESPACE",
                valueFrom: {
                  fieldRef: {
                    fieldPath: "metadata.namespace",
                  },
                },
              },
              {
                name: "INSTANCE_IP",
                valueFrom: {
                  fieldRef: {
                    fieldPath: "status.podIP",
                  },
                },
              },
              {
                name: "ISTIO_META_POD_NAME",
                valueFrom: {
                  fieldRef: {
                    fieldPath: "metadata.name",
                  },
                },
              },
              {
                name: "ISTIO_META_INTERCEPTION_MODE",
                value: "REDIRECT",
              },
            ],
            image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/shaktiprakash-das/istio/proxyv2:1.0.2",
            imagePullPolicy: "IfNotPresent",
            name: "istio-proxy",
            resources: {
              requests: {
                cpu: "10m",
              },
            },
            securityContext: {
              readOnlyRootFilesystem: true,
              runAsUser: 1337,
            },
            volumeMounts: [
              {
                mountPath: "/etc/istio/proxy",
                name: "istio-envoy",
              },
              {
                mountPath: "/etc/certs/",
                name: "istio-certs",
                readOnly: true,
              },
            ],
          },
        ],
        initContainers: [
          {
            args: [
              "-p",
              "15001",
              "-u",
              "1337",
              "-m",
              "REDIRECT",
              "-i",
              "*",
              "-x",
              "",
              "-b",
              "7021",
              "-d",
              "",
            ],
            image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/shaktiprakash-das/istio/proxy_init:1.0.2",
            imagePullPolicy: "IfNotPresent",
            name: "istio-init",
            resources: {
            },
            securityContext: {
              capabilities: {
                add: [
                  "NET_ADMIN",
                ],
              },
            },
          },
        ],
        volumes: [
          {
            emptyDir: {
              medium: "Memory",
            },
            name: "istio-envoy",
          },
          {
            name: "istio-certs",
            secret: {
              optional: true,
              secretName: "istio.default",
            },
          },
        ],
      },
    },
  },
  status: {
  },
} else "SKIP"
