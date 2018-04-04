local configs = import "config.jsonnet";
local storageimages = (import "storageimages.jsonnet") + { templateFilename:: std.thisFile };
local storageutils = import "storageutils.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";
local isEstateNotSkipper = configs.estate != "prd-skipper";
// Defines the list of estates where this service is enabled.
local enabledEstates = std.set([
    "prd-sam_storage",
    "prd-sam",
    "prd-skipper",
    "phx-sam",
]);

// Environment variables for the Local Provisioner container.
local lvEnvironmentVars = std.prune([
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
]) +
if isEstateNotSkipper then
  [
    {
        name: "KUBECONFIG",
        value: "/kubeconfig/kubeconfig",
    },
  ]
else [];


local internal = {
    provisioner_node_affinity(estate):: (
        if isEstateNotSkipper then {
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
        } else {}
    ),
};
if std.setMember(configs.estate, enabledEstates) then {
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        name: "lv-os-provisioner",
        namespace: "storage-foundation",
        labels: {
            team: "storage-foundation",
        cloud: "storage",
        },
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
                affinity: internal.provisioner_node_affinity(configs.estate),
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
                    ] + storageutils.cert_volume_mounts()
                    + storageutils.log_init_volume_mounts()),
                    env: lvEnvironmentVars,
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
                ] + storageutils.cert_volume() + storageutils.log_init_volumes()),
            },
        },
    },
} else "SKIP"
