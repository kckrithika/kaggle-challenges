local configs = import "config.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local versions = import "stampy/versions.jsonnet";
local stampy_utils = import "stampy/stampy_utils.jsonnet";
local maddogInit = import "stampy/maddog/_init-cert-container.jsonnet";
local maddogPermissions = import "stampy/maddog/_init-permissions-container.jsonnet";
local maddogRefresher = import "stampy/maddog/_cert-refresher-container.jsonnet";
local utils = import "util_functions.jsonnet";
local funnelEndpointHost = std.split(configs.funnelVIP, ":")[0];
local funnelEndpointPort = std.split(configs.funnelVIP, ":")[1];

if stampy_utils.is_stampy_webhook_dev_cluster(configs.estate) then
configs.deploymentBase("stampy") {
  metadata+: {
    name: "stampy-webhook-deployment",
    namespace: versions.injectorNamespace,
    labels: {
      app: "stampy-webhook",
    } +
    // samlabelfilter.json requires this label to be present on GCP deployments
    if utils.is_pcn(configs.kingdom) then configs.pcnEnableLabel else {},
  },
  spec+: {
    replicas: if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || utils.is_pcn(configs.kingdom) then 1 else 3,
    template: {
      metadata: {
        labels: {
          app: "stampy-webhook",
          name: "stampy-webhook",
          "stampy-webhook/disable": "true",
        },
        annotations: {
          "stampy-webhook/disable": "true",
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
                    role: "stampy-webhook",
                    san: [
                      "stampy-webhook",
                      "stampy-webhook.%s" % versions.injectorNamespace,
                      "stampy-webhook.%s.svc" % versions.injectorNamespace,
                      "stampy-webhook.%s.svc.cluster.local" % versions.injectorNamespace,
                      "stampy-webhook.%s.svc.%s" % [
                        versions.injectorNamespace,
                        (if configs.estate == "gsf-core-devmvp-sam2-sam" then "gsf-core-devmvp-sam2-samtest.mvp.sam.sfdc.net" else configs.dnsdomain),
                      ],
                    ],
                  },
                  {
                    "cert-type": "client",
                    kingdom: configs.kingdom,
                    name: "cert2",
                    role: "stampy-webhook",
                    san: [
                      "stampy-webhook",
                      "stampy-webhook.%s" % versions.injectorNamespace,
                      "stampy-webhook.%s.svc" % versions.injectorNamespace,
                      "stampy-webhook.%s.svc.cluster.local" % versions.injectorNamespace,
                      "stampy-webhook.%s.svc.%s" % [
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
            name: "stampy-webhook",
            image: versions.stampyWebhookImage,
            imagePullPolicy: "Always",
            terminationMessagePolicy: "FallbackToLogsOnError",
            args: [
              "-tls-port=17772",
              "-http-port=17773",
              "-cert-file-path=/server-certs/server/certificates/server.pem",
              "-key-file-path=/server-certs/server/keys/server-key.pem",
              "-allow-if-error=true",
              "-log-level=debug"
            ],
            env+:[
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
                    name: "POD",
                    value: "-",
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
                  name: "SFDC_SETTINGS_PATH",
                  value: "stampy.-." + configs.kingdom + ".-.stampy-webhook",
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
                containerPort: 17772,
              },
            ],
          },
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
