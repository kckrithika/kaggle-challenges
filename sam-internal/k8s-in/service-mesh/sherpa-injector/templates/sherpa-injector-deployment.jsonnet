local configs = import "config.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local versions = import "service-mesh/sherpa-injector/versions.jsonnet";
local maddogInit = import "service-mesh/sherpa-injector/maddog/_init-cert-container.jsonnet";
local maddogPermissions = import "service-mesh/sherpa-injector/maddog/_init-permissions-container.jsonnet";
local maddogRefresher = import "service-mesh/sherpa-injector/maddog/_cert-refresher-container.jsonnet";
local funnelEndpointHost = std.split(configs.funnelVIP, ":")[0];
local funnelEndpointPort = std.split(configs.funnelVIP, ":")[1];
local enableSherpa = false;

configs.deploymentBase("service-mesh") {
  metadata+: {
    name: "sherpa-injector",
    namespace: "service-mesh",
    labels: {
      app: "sherpa-injector",
    },
  },
  spec+: {
    replicas: if configs.estate == "prd-samtest" then 1 else 3,
    template: {
      metadata: {
        labels: {
          app: "sherpa-injector",
          "sherpa-injector.service-mesh/inject": "disabled",
        },
        annotations: {
          "scheduler.alpha.kubernetes.io/critical-pod": "",
          "madkub.sam.sfdc.net/allcerts":
          std.manifestJsonEx(
            {
              certreqs:
                [
                  {
                    "cert-type": "server",
                    kingdom: configs.kingdom,
                    name: "cert1",
                    role: "sherpa-injector",
                    san: [
                      "sherpa-injector",
                      "sherpa-injector.service-mesh",
                      "sherpa-injector.service-mesh.svc",
                      "sherpa-injector.service-mesh.svc.%s" % configs.dnsdomain,
                    ],
                  },
                  {
                    "cert-type": "client",
                    kingdom: configs.kingdom,
                    name: "cert2",
                    role: "sherpa-injector",
                    san: [
                      "sherpa-injector",
                      "sherpa-injector.service-mesh",
                      "sherpa-injector.service-mesh.svc",
                      "sherpa-injector.service-mesh.svc.%s" % configs.dnsdomain,
                    ],
                  },
                ],
            }, " "
          ),
        },
      },
      spec: configs.specWithKubeConfigAndMadDog {
        containers: [
          {
            name: "injector",
            image: versions.injectorImage,
            imagePullPolicy: "IfNotPresent",
            args: [
              "--template=sherpa-container.yaml.template",
              "--image=%s" % versions.sherpaImage,
              "--log-level=debug",
            ] +
            if enableSherpa then [
              // h1 port to use with Sherpa
              "--port=7022",
            ] else [
              "--port=7442",  // use the same port as we use in Sherpa (h1 TLS IN)
              "--cert=/server-certs/server/certificates/server.pem",
              "--key=/server-certs/server/keys/server-key.pem",
            ] +
            if std.length(versions.canarySherpaImage) > 0 then [
              "--canary-image=%s" % versions.canarySherpaImage,
            ],
            env+: [
              {
                name: "SFDC_ENVIRONMENT",
                value: "mesh",
              },
              {
                name: "SETTINGS_SERVICENAME",
                value: "sherpa-injector",
              },
              {
                name: "FUNCTION_NAMESPACE",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "metadata.namespace", apiVersion: "v1" },
                  },
              },
              {
                name: "FUNCTION_INSTANCE_NAME",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "metadata.name", apiVersion: "v1" },
                  },
              },
              {
                name: "FUNCTION_INSTANCE_IP",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "status.podIP", apiVersion: "v1" },
                  },
              },
              {
                name: "FUNCTION",
                value: "sherpa-injector",
              },
              {
                name: "KINGDOM",
                value: configs.kingdom,
              },
              {
                name: "ESTATE",
                value: configs.estate,
              },
              {
                name: "SUPERPOD",
                value: "-",
              },
              {
                name: "SETTINGS_SUPERPOD",
                value: "-",
              },
              {
                name: "SETTINGS_PATH",
                value: "mesh.-." + configs.kingdom + ".-.sherpa-injector",
              },
              {
                name: "SFDC_SETTINGS_PATH",
                value: "mesh.-." + configs.kingdom + ".-.sherpa-injector",
              },
              {
                name: "SFDC_METRICS_SERVICE_HOST",
                value: funnelEndpointHost,
              },
              {
                name: "SFDC_METRICS_SERVICE_PORT",
                value: funnelEndpointPort,
              },
            ],
            volumeMounts+: [
              {
                name: "cert1",
                mountPath: "/server-certs",
              },
              {
                name: "cert2",
                mountPath: "/client-certs",
              },
            ],
            ports+: [
              {
                containerPort: if enableSherpa then 7022 else 7442,
              },
            ],
            livenessProbe: {
              exec: {
                command: [
                  "./is-alive.sh",
                  if enableSherpa then "7022" else "7442",
                ] +
                if !enableSherpa then [
                  // Pass the certificates folder for the liveness probe to use TLS
                  "/client-certs/client/certificates/client.pem",
                  "/client-certs/client/keys/client-key.pem",
                ],
              },
              initialDelaySeconds: 2,
              periodSeconds: 3,
            },
            readinessProbe: {
              exec: {
                command: [
                  "./is-ready.sh",
                  if enableSherpa then "7022" else "7442",
                ] +
                if !enableSherpa then [
                  // Pass certificates for the readiness probe to use with TLS
                  "/client-certs/client/certificates/client.pem",
                  "/client-certs/client/keys/client-key.pem",
                ],
              },
              initialDelaySeconds: 4,
              periodSeconds: 3,
            },
            resources: {},
          },
          maddogRefresher.madkubRefresherContainer,
        ] +
        if enableSherpa then [{
            name: "sherpa",
            image: versions.sherpaImage,
            imagePullPolicy: "IfNotPresent",
            args: [
              "--log-level=debug",
            ],
            env+: [
              {
                name: "SFDC_ENVIRONMENT",
                value: "mesh",
              },
              {
                name: "SETTINGS_SERVICENAME",
                value: "sherpa-injector",
              },
              {
                name: "FUNCTION_NAMESPACE",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "metadata.namespace", apiVersion: "v1" },
                  },
              },
              {
                name: "FUNCTION_INSTANCE_NAME",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "metadata.name", apiVersion: "v1" },
                  },
              },
              {
                name: "FUNCTION_INSTANCE_IP",
                valueFrom:
                  {
                    fieldRef: { fieldPath: "status.podIP", apiVersion: "v1" },
                  },
              },
              {
                name: "FUNCTION",
                value: "sherpa-injector",
              },
              {
                name: "KINGDOM",
                value: configs.kingdom,
              },
              {
                name: "ESTATE",
                value: configs.estate,
              },
              {
                name: "SUPERPOD",
                value: "-",
              },
              {
                name: "SETTINGS_SUPERPOD",
                value: "-",
              },
              {
                name: "SETTINGS_PATH",
                value: "mesh.-." + configs.kingdom + ".-.sherpa-injector",
              },
              {
                name: "SFDC_SETTINGS_PATH",
                value: "mesh.-." + configs.kingdom + ".-.sherpa-injector",
              },
              {
                name: "SFDC_METRICS_SERVICE_HOST",
                value: funnelEndpointHost,
              },
              {
                name: "SFDC_METRICS_SERVICE_PORT",
                value: funnelEndpointPort,
              },
            ],

            volumeMounts+: [
              {
                name: "cert1",
                mountPath: "/server-certs",
              },
              {
                name: "cert2",
                mountPath: "/client-certs",
              },
            ],
            ports: [
              {
                // h1-in
                containerPort: 7014,
              },
              {
                // h1-tls-in
                containerPort: 7442,
              },
              {
                // admin
                containerPort: 15373,
              },
            ],
            livenessProbe: {
              exec: {
                command: [
                  "./bin/is-alive",
                ],
              },
              initialDelaySeconds: 5,
              periodSeconds: 5,
            },
            readinessProbe: {
              exec: {
                command: [
                  "./bin/is-ready",
                ],
              },
              initialDelaySeconds: 4,
              periodSeconds: 5,
            },
            resources: {
              limits: {
                cpu: "1",
                memory: "1Gi",
              },
              requests: {
                cpu: "1",
                memory: "1Gi",
              },
            },
        }] else [],
        # In PRD only kubeapi (master) nodes get cluster-admin permission
        # In production, SAM control estate nodes get cluster-admin permission
        nodeSelector: {} +
          if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then {
              master: "true",
          } else {
              pool: configs.estate,
          },
        volumes+: [
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
        ],
        initContainers+: [
          maddogInit.madkubInitContainer,
          maddogPermissions.permissionSetterInitContainer,
        ],
      },
    },
  },
}
