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
            image: "ops0-artifactrepo1-0-prd.data.sfdc.net/dva/mutating-webhook:120-198f5792279c9a1ca1e490c0281590bb1efd275c",
            imagePullPolicy: "IfNotPresent",
            terminationMessagePolicy: "FallbackToLogsOnError",
            args: [
              "/mutating-webhook/mutating-webhook",
              "--sidecar-config-file=/etc/webhook/config/sidecarconfig.yaml",
              "--mutation-config-file=/etc/webhook/config/mutationconfig.yaml",
              "--cert-file-path=/server-certs/server/certificates/server.pem",
              "--key-file-path=/server-certs/server/keys/server-key.pem",
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
                value: "1",
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
                name: "electron-opa-injector-config",
                mountPath: "/config",
              },
            ],
            ports+: [
              {
                containerPort: 17442,
              },
            ],
            livenessProbe: {
              httpGet: {
                scheme: "HTTPS",
                path: "/healthz",
                port: "8443",
              },
              initialDelaySeconds: 2,
              periodSeconds: 10,
            },
            readinessProbe: {
              httpGet: {
                scheme: "HTTPS",
                path: "/healthz",
                port: "8443",
              },
              initialDelaySeconds: 5,
              periodSeconds: 10,
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
              name: "electron-opa-injector-config",
            },
            name: "electron-opa-injector-config",
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
