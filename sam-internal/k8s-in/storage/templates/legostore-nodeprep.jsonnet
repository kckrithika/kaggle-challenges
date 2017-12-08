local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" || configs.estate == "phx-sam" then {

    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
      name: "legostore-nodeprep",
      namespace: "storage-foundation",
    },
    spec: {
      template: {
        metadata: {
          labels: {
            app: "legostore-nodeprep",
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
                          values: ["prd-sam_cephdev", "prd-sam_ceph", "phx-sam_ceph"],
                       },
                       {
                          key: "storage.salesforce.com/nodeprep",
                          operator: "DoesNotExist",
                       },
                     ] + if configs.estate == "phx-sam" then [{
                                                                key: "kubernetes.io/hostname",
                                                                operator: "In",
                                                                values: ["shared0-samminionceph1-1-phx.ops.sfdc.net"],
                                                             }] else [],
                  },
                ],
              },
            },
          },
          containers: [
            {
              name: "nodeprep",
              image: storageimages.sfnodeprep,
              imagePullPolicy: "Always",
              securityContext: {
                privileged: true,
              },
              volumeMounts: configs.filter_empty([
                {
                  name: "hdd-vols",
                  mountPath: "/local-hdds",
                },
                {
                  name: "ssd-vols",
                  mountPath: "/local-ssds",
                },
                {
                  name: "hostfs",
                  mountPath: "/hostfs",
                },
                {
                  name: "nodeprep-config",
                  mountPath: "/etc/node-config",
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
                  name: "KUBECONFIG",
                  value: "/kubeconfig/kubeconfig",
                },
                {
                  name: "HOST_FS",
                  value: "/hostfs",
                },
                {
                  name: "DELETE_DISCOVERY",
                  value: "no",
                },
              ],
            },
          ],
          volumes: configs.filter_empty([
            {
              name: "hdd-vols",
              hostPath: {
                 path: "/mnt/lvhdds",
              },
            },
            {
              name: "ssd-vols",
              hostPath: {
                path: "/mnt/lvssds",
              },
            },
            {
              name: "hostfs",
              hostPath: {
                path: "/",
              },
            },
            {
               name: "nodeprep-config",
               configMap: {
                 name: "legostore-nodeprep-config",
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
