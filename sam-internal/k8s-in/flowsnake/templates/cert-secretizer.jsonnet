local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnake_config = import "flowsnake_config.jsonnet";
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local madkub_common = import "madkub_common.jsonnet";
local cert_name = "ingresscerts";
local configs = import "config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local public_name = "ingress";

if flowsnake_config.is_v1_enabled then configs.deploymentBase("flowsnake") {
  local label_node = self.spec.template.metadata.labels,
  metadata: {
    name: "cert-secretizer",
    namespace: "flowsnake",
  },
  spec+: {
    replicas: 1,
    minReadySeconds: 45,
    selector: {
      matchLabels: {
        name: label_node.name,
      },
    },
    template: {
      metadata: {
        annotations: {
            "madkub.sam.sfdc.net/allcerts": std.toString({
              certreqs: [
                {
                  name: cert_name,
                  role: "flowsnake." + flowsnake_config.role_munge_for_estate("api"),
                  san: [
                    flowsnake_config.fleet_vips[estate],
                    flowsnake_config.service_mesh_fqdn("api"),
                  ] + (if std.objectHas(flowsnake_images.feature_flags, "slb_ingress") then
                    [flowsnake_config.slb_fqdn(public_name)] else []),
                  "cert-type": "server",
                  kingdom: kingdom,
                },
              ],
             }),
        },
        labels: {
          name: "cert-secretizer",
          flowsnakeOwner: "dva-transform",
          flowsnakeRole: "FlowsnakeCertSecretizer",
        },
      },
      spec: {
        containers: [
            {
            name: "cert-secretizer",
            image: flowsnake_images.cert_secretizer,
            imagePullPolicy: if flowsnake_config.is_minikube then "Never" else "Always",
            volumeMounts: [
              {
                mountPath: "/certToSecretConfigs",
                name: "certs-to-secrets",
              },
              {
                mountPath: "/etc/flowsnake/config/auth-namespaces",
                name: "auth-namespaces",
                readOnly: true,
              },
            ] +
            madkub_common.cert_mounts(cert_name) +
            (if !flowsnake_config.is_minikube then
                certs_and_kubeconfig.kubeconfig_volumeMounts +
                certs_and_kubeconfig.platform_cert_volumeMounts
            else []),
            env: [
              {
                name: "FLOWSNAKE_FLEET",
                valueFrom: {
                  configMapKeyRef: {
                    name: "fleet-config",
                    key: "name",
                  },
                },
              },
              {
                name: "KUBECONFIG",
                valueFrom: {
                  configMapKeyRef: {
                    name: "fleet-config",
                    key: "kubeconfig",
                  },
                 },
              },
            ],
          },
          ] + [madkub_common.refresher_container(cert_name)],
        initContainers: [madkub_common.init_container(cert_name)],
        restartPolicy: "Always",
        volumes: [
          {
            name: "certs-to-secrets",
            configMap: {
              name: "certs-to-secrets",
            },
          },
          {
            name: "auth-namespaces",
            configMap: {
              name: "auth-namespaces",
            },
          },
        ]
          + madkub_common.cert_volumes(cert_name)
          + if !flowsnake_config.is_minikube then certs_and_kubeconfig.kubeconfig_platform_volume
                else [
                {
                  hostPath: {
                      path: "/tmp/sc_repo",
                  },
                  name: "maddog-onebox-certs",
                },
],
      },
    },
  },
} else "SKIP"
