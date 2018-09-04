local configs = import "config.jsonnet";
local storageimages = (import "storageimages.jsonnet") + { templateFilename:: std.thisFile };
local storageutils = import "storageutils.jsonnet";
// Configures the set of minion estates that nodeprep undo runs in, applied as a node selector
// term.  Currently disabled -- no minion estates need cleanup at this time.
local enabledMinionEstates = ["not-in-any-pool-at-this-time"];

if configs.estate == "prd-sam_storage" then configs.daemonSetBase("storage") {

    metadata: {
      name: "legostore-nodeprep-undo",
      namespace: "storage-foundation",
      labels: {
        team: "storage-foundation",
        cloud: "storage",
      } + configs.ownerLabel.storage,
    },
    spec+: {
      template: {
        metadata: {
          labels: {
            app: "legostore-nodeprep-undo",
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
                          values: enabledMinionEstates,
                       },
                       {
                          key: "storage.salesforce.com/nodeprep",
                          operator: "In",
                          values: ["cleanup"],
                       },
                     ],
                  },
                ],
              },
            },
          },
          initContainers: [
            {} +
            storageimages.log_init_container(
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
              image: storageimages.nodeprep,
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
                  name: "procpath",
                  mountPath: "/hostroot/proc",
                },
                {
                  name: "discoverypath",
                  mountPath: "/hostroot/mnt",
                },
                {
                  name: "fstabpath",
                  mountPath: "/hostroot/etc",
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
                  name: "PROC_PATH",
                  value: "/hostroot/proc",
                },
                {
                  name: "DISCOVERY_PATH",
                  value: "/hostroot/mnt",
                },
                {
                  name: "FSTAB_PATH",
                  value: "/hostroot/etc",
                },
                {
                  name: "DELETE_DISCOVERY",
                  value: "yes",
                },
              ] + [configs.kube_config_env],
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
              name: "procpath",
              hostPath: {
                path: "/proc",
              },
            },
            {
              name: "fstabpath",
              hostPath: {
                path: "/etc",
              },
            },
            {
              name: "discoverypath",
              hostPath: {
                path: "/mnt",
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
          ] + storageutils.log_init_volumes()),
        },
      },
   },
} else "SKIP"
