local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";
local storageutils = import "storageutils.jsonnet";

if configs.estate == "disable" then {

    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
      name: "sfstore-nodeprep",
      namespace: "storage-foundation",
    },
    spec: {
      template: {
        metadata: {
          labels: {
            app: "sfstore-nodeprep",
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
                          values: ["prd-sam_sfstore"],
                       },
                       {
                          key: "storage.salesforce.com/nodeprep",
                          operator: "DoesNotExist",
                       },
                     ],
                  },
                ],
              },
            },
          },
          initContainers: [
            {} +
            storageutils.log_init_container(
              storageimages.loginit,
              "localvol",
              0,
              0,
              "root"
            ),
          ],
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
              ] + storageutils.log_init_volume_mounts()),
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
                 name: "sfstore-nodeprep-config",
               },
            },
            configs.maddog_cert_volume,
            configs.cert_volume,
            configs.kube_config_volume,
          ] + storageutils.log_init_volumes()),
        },
      },
   },
} else "SKIP"
