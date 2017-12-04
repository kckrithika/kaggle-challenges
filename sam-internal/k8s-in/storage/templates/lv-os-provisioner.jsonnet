local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";

if configs.estate == "prd-sam_storage" then {

    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
      name: "lv-os-provisioner",
      namespace: "lvns",
    },
    spec: {
      template: {
        metadata: {
          labels: {
            app: "lv-os-provisioner",
          },
        },
        spec: {
          hostNetwork: true,
          affinity: {
            nodeAffinity: {
              requiredDuringSchedulingIgnoredDuringExecution: {
                nodeSelectorTerms: [
                  {
                     matchExpressions: [
                       {
                          key: "pool",
                          operator: "In",
                          values: ["prd-sam_cephdev"],
                       },
                       {
                          key: "storage.salesforce.com/nodeprep",
                          operator: "In",
                          values: ["mounted"],
                       },
                     ],
                  },
                ],
              },
            },
          },
          containers: [
            {
              name: "provisioner",
              image: storageimages.lvprovisioner,
              imagePullPolicy: "Always",
              securityContext: {
                privileged: true,
              },
              volumeMounts: configs.filter_empty([
                {
                  name: "hdd-vols",
                  mountPath: "/local-hdd",
                },
                {
                  name: "ssd-vols",
                  mountPath: "/local-ssd",
                },
                {
                  name: "local-volume-sfdc-config",
                  mountPath: "/etc/provisioner/config",
                },
                configs.maddog_cert_volume_mount,
                configs.cert_volume_mount,
                configs.kube_config_volume_mount,
              ]),
              env: [
                {
                  name: "MY_NODE_NAME",
                  valueFrom: {
                    fieldRef: {
                      fieldPath: "spec.nodeName",
                    },
                  },
                },
                {
                  name: "MY_NAMESPACE",
                  value: "lvns",
                },
                {
                  name: "KUBECONFIG",
                  value: "/kubeconfig/kubeconfig",
                },
              ],
            },
          ],
          volumes: configs.filter_empty([
            {
              name: "hdd-vols",
              hostPath: {
                 path: "/mnt/lvhdd",
              },
            },
            {
              name: "ssd-vols",
              hostPath: {
                path: "/mnt/lvssd",
              },
            },
            {
               name: "local-volume-sfdc-config",
               configMap: {
                 name: "local-volume-sfdc-config",
               },
            },
            configs.maddog_cert_volume,
            configs.cert_volume,
            configs.kube_config_volume,
          ]),
        },
      },
   },
} else "SKIP"
