local configs = import "config.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local versions = import "authz/versions.jsonnet";
local electron_opa_utils = import "authz/electron_opa_utils.jsonnet";
local maddogInit = import "service-mesh/sherpa-injector/maddog/_init-cert-container.jsonnet";
local maddogPermissions = import "service-mesh/sherpa-injector/maddog/_init-permissions-container.jsonnet";
local maddogRefresher = import "service-mesh/sherpa-injector/maddog/_cert-refresher-container.jsonnet";
local utils = import "util_functions.jsonnet";
local funnelEndpointHost = std.split(configs.funnelVIP, ":")[0];
local funnelEndpointPort = std.split(configs.funnelVIP, ":")[1];

if electron_opa_utils.is_electron_opa_injector_test_cluster(configs.estate) then
configs.deploymentBase("authz-injector") {
  metadata+: {
    name: "electron-opa-injector",
    namespace: versions.injectorNamespace,
    labels: {
      app: "electron-opa-injector",
    } +
    // samlabelfilter.json requires this label to be present on GCP deployments
    if utils.is_pcn(configs.kingdom) then configs.pcnEnableLabel else {},
  },
  spec+: {
    replicas: 1,
    template: {
      metadata: {
        labels: {
          app: "electron-opa-injector",
          name: "electron-opa-injector",
          "electron-opa-injector.authz/inject": "disabled",
        },
        annotations: {
          "electron-opa-injector.authz/inject": "disabled",
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
                    role: "electron-opa-injector",
                    san: [
                      "electron-opa-injector",
                      "electron-opa-injector.%s" % versions.injectorNamespace,
                      "electron-opa-injector.%s.svc" % versions.injectorNamespace,
                      "electron-opa-injector.%s.svc.cluster.local" % versions.injectorNamespace,
                      "electron-opa-injector.%s.svc.%s" % [
                        versions.injectorNamespace,
                        (if configs.estate == "gsf-core-devmvp-sam2-sam" then "gsf-core-devmvp-sam2-samtest.mvp.sam.sfdc.net" else configs.dnsdomain),
                      ],
                    ],
                  },
                  {
                    "cert-type": "client",
                    kingdom: configs.kingdom,
                    name: "cert2",
                    role: "electron-opa-injector",
                    san: [
                      "electron-opa-injector",
                      "electron-opa-injector.%s" % versions.injectorNamespace,
                      "electron-opa-injector.%s.svc" % versions.injectorNamespace,
                      "electron-opa-injector.%s.svc.cluster.local" % versions.injectorNamespace,
                      "electron-opa-injector.%s.svc.%s" % [
                        versions.injectorNamespace,
                        (if configs.estate == "gsf-core-devmvp-sam2-sam" then "gsf-core-devmvp-sam2-samtest.mvp.sam.sfdc.net" else configs.dnsdomain),
                      ],
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
            image: "ops0-artifactrepo2-0-prd.data.sfdc.net/dva/electron-opa-injection-webhook:18-f5a35ecc641b6cf83c12ef4de716b98a37b4344e",
            imagePullPolicy: "IfNotPresent",
            terminationMessagePolicy: "FallbackToLogsOnError",
            args: [
              "--opa-template=%s" % "/config/electron-opa-container.yaml.template",  // This is the template that we have stored in a ConfigMap in k8s
              "--opa-istio-template=%s" % "/config/electron-opa-istio-container.yaml.template",  // This is the template that we have stored in a ConfigMap in k8s
              "--opa-image=ops0-artifactrepo2-0-prd.data.sfdc.net/dva/electron_opa:9-406399d98e8627a11303098578e595b3d84ab4ed",
              "--opa-istio-image=ops0-artifactrepo2-0-prd.data.sfdc.net/dva/electron_opa_istio:9-406399d98e8627a11303098578e595b3d84ab4ed",
              "--log-level=debug",
              "--port=17442",
              "--cert=/server-certs/server/certificates/server.pem",
              "--key=/server-certs/server/keys/server-key.pem",
            ],
            env+: [
              {
                name: "SFDC_ENVIRONMENT",
                value: "mesh",
              },
              {
                name: "SETTINGS_SERVICENAME",
                value: "electron-opa-injector",
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
                value: "electron-opa-injector",
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
                value: "mesh.-." + configs.kingdom + ".-.electron-opa-injector",
              },
              {
                name: "SFDC_SETTINGS_PATH",
                value: "mesh.-." + configs.kingdom + ".-.electron-opa-injector",
              },
              {
                name: "SFDC_METRICS_SERVICE_HOST",
                // use `value: funnelEndpointHost,` if direct link to ajna is needed
                value: funnelEndpointHost,
              },
              {
                name: "SFDC_METRICS_SERVICE_PORT",
                // use `value: funnelEndpointPort,` if direct link to ajna is needed
                value: funnelEndpointPort,
              },
              {
                name: "FAKE_REDEPLOY_VAR",
                value: "0",
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
              {
                name: "electron-opa-sherpa-container",
                mountPath: "/config/electron-opa-container.yaml.template",
              },
              {
                name: "electron-opa-istio-sherpa-container",
                mountPath: "/config/electron-opa-istio-container.yaml.template",
              },
              {
                name: "electron-opa-no-sherpa-container",
                mountPath: "/config/electron-opa-no-sherpa-container.yaml.template",
              },
              {
                name: "electron-opa-istio-no-sherpa-container",
                mountPath: "/config/electron-opa-istio-no-sherpa-container.yaml.template",
              },
            ],
            ports+: [
              {
                containerPort: 17442,
              },
            ],
            livenessProbe: {
              exec: {
                command: [
                  "./tools/is-alive.sh",
                  "17442",
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
                  "./tools/is-ready.sh",
                  "17442",
                  // Pass certificates for the readiness probe to use with TLS
                  "/client-certs/client/certificates/client.pem",
                  "/client-certs/client/keys/client-key.pem",
                ],
              },
              initialDelaySeconds: 4,
              periodSeconds: 3,
            },
            resources: {},
          } + configs.ipAddressResourceRequest,
          maddogRefresher.madkubRefresherContainer,
        ],
        # In PRD only kubeapi (master) nodes get cluster-admin permission
        # In production, SAM control estate nodes get cluster-admin permission
        nodeSelector: {} +
          if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
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
          {
            configMap: {
              name: "electron-opa-sherpa-container",
            },
            name: "electron-opa-sherpa-container",
          },
          {
            configMap: {
              name: "electron-opa-istio-sherpa-container",
            },
            name: "electron-opa-istio-sherpa-container",
          },
          {
            configMap: {
              name: "electron-opa-no-sherpa-container",
            },
            name: "electron-opa-no-sherpa-container",
          },
          {
            configMap: {
              name: "electron-opa-istio-no-sherpa-container",
            },
            name: "electron-opa-istio-no-sherpa-container",
          },
        ] +
        if utils.is_pcn(configs.kingdom) then
        [
          {
            hostPath: {
              path: "/etc/pki_service",
            },
            name: "maddog-certs",
          },
        ]
        else [],
        initContainers+: [
          maddogInit.madkubInitContainer,
          maddogPermissions.permissionSetterInitContainer,
        ],
      },
    },
  },
} else "SKIP"