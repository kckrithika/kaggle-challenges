local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local auto_deployer = import "auto_deployer.jsonnet";
local configs = import "config.jsonnet";
local flag_fs_metric_labels = std.objectHas(flowsnake_images.feature_flags, "fs_metric_labels");
local flag_fs_matchlabels = std.objectHas(flowsnake_images.feature_flags, "fs_matchlabels");

if !auto_deployer.auto_deployer_enabled then
"SKIP"
else
configs.deploymentBase("flowsnake") {
  local label_node = self.spec.template.metadata.labels,
  metadata: {
    labels: {
      name: "samcontrol-deployer",
    },
    name: "samcontrol-deployer",
    namespace: "sam-system",
  },
  spec: {
    replicas: 1,
    [if flag_fs_matchlabels then "selector"]: {
      matchLabels: {
        apptype: label_node.apptype,
        name: label_node.name,
      },
    },
    template: {
      metadata: {
        labels: {
          apptype: "control",
          name: "samcontrol-deployer",
        } + if flag_fs_metric_labels then {
          flowsnakeOwner: "dva-transform",
          flowsnakeRole: "SamControlDeployer",
        } else {},
      },
      spec: {
        containers: [
          {
            command: [
              "/sam/samcontrol-deployer",
              "--config=/config/samcontroldeployer.json",
              "--hostsConfigFile=/sfdchosts/hosts.json",
            ],
            env: [
              {
                name: "KUBECONFIG",
                value: "/kubeconfig/kubeconfig-platform",
              },
            ],
            image: flowsnake_images.deployer,
            livenessProbe: {
              httpGet: {
                path: "/",
                port: 9099,
              },
              initialDelaySeconds: 2,
              periodSeconds: 10,
              timeoutSeconds: 10,
            },
            name: "samcontrol-deployer",
            volumeMounts: [
              {
                mountPath: "/sfdchosts",
                name: "sfdchosts",
              },
              {
                mountPath: "/etc/pki_service",
                name: "maddog-certs",
              },
              {
                mountPath: "/kubeconfig",
                name: "kubeconfig",
              },
              {
                mountPath: "/config",
                name: "config",
              },
            ] + (
if std.objectHas(flowsnake_images.feature_flags, "del_certsvc_certs") then [] else
              [{
                mountPath: "/data/certs",
                name: "certs",
              }]
            ),
          },
        ],
        hostNetwork: true,
        volumes: [
          {
            configMap: {
              name: "sfdchosts",
            },
            name: "sfdchosts",
          },
          {
            hostPath: {
              path: "/etc/pki_service",
            },
            name: "maddog-certs",
          },
          {
            hostPath: {
              path: "/etc/kubernetes",
            },
            name: "kubeconfig",
          },
          {
            configMap: {
              name: "samcontrol-deployer",
            },
            name: "config",
          },
        ] + (
if std.objectHas(flowsnake_images.feature_flags, "del_certsvc_certs") then [] else [
          {
            hostPath: {
              path: "/data/certs",
            },
            name: "certs",
          },
]
        ),
      },
    },
  },
}
