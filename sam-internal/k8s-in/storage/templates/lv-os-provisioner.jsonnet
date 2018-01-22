local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";
local storageutils = import "storageutils.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" || configs.estate == "phx-sam" then {

    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
      name: "lv-os-provisioner",
      namespace: "storage-foundation",
      team: "storage-foundation",
      cloud: "storage",
    },
    spec: {
      template: {
        metadata: {
          labels: {
            app: "lv-os-provisioner",
            team: "storage-foundation",
            cloud: "storage",
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
                          values: storageconfigs.storageEstates,
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
          ] + storageutils.log_init_volumes()),
        },
      },
   },
} else "SKIP"
