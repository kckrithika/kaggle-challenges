local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";
local storageutils = import "storageutils.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "phx-sam" then {
   apiVersion: "extensions/v1beta1",
   kind: "Deployment",
   metadata: {
      name: "ceph-metrics",
      namespace: "legostore",
      labels: {
         team: "legostore",
         cloud: "storage",
      },
   },
   spec: {
      replicas: 1,
      template: {
         metadata: {
            labels: {
               app: "ceph-metrics",
               team: "legostore",
               cloud: "storage",
            },
         },
         spec: {
            nodeSelector: {
            } +
            if configs.estate == "phx-sam" then {
                  pool: configs.estate,
            } else {
                  pool: storageconfigs.cephMetricsPool,
            },
            volumes: [
               {
                  name: "kubernetes",
                  hostPath: {
                     path: "/etc/kubernetes",
                  },
               },
               {
                  name: "ceph-conf",
                  emptyDir: {},
               },
               {
                  name: "key-conf",
                  secret: {
                     secretName: "ceph-client-key",
                  },
               },
               {
                  name: "ceph-cluster-conf",
                  configMap: {
                     name: "ceph-cluster",
                  },
               },
            ],
            containers: [
               {
                  name: "sfms",
                  image: storageimages.sfms,
                  imagePullPolicy: "IfNotPresent",
                  command: [
                     "/opt/sfms/bin/sfms",
                  ],
                  args: [
                     "-m",
                     "snapshot_for_cephmon",
                     "-t",
                     "ajna_with_tags",
                     "-s",
                     "cephmon",
                     "-i",
                     '60',
                  ],
                  ports: [
                     {
                        name: "ceph-metrics",
                        containerPort: 8001,
                        protocol: "TCP",
                     },
                  ],
                  volumeMounts: [
                     {
                        name: "ceph-conf",
                        mountPath: "/etc/ceph",
                     },
                  ],
                  env: storageutils.sfms_environment_vars("ceph"),
               },
               {
                  name: "configwatcher",
                  image: storageimages.configwatcher,
                  args: [
                     "-ceph-key-config-dir=/etc/ceph-metrics/key-config",
                     "-ceph-cluster-config-dir=/etc/ceph-metrics/ceph-cluster-config",
                     "-ceph-config-dir=/etc/ceph",
                  ],
                  volumeMounts: [
                     {
                        name: "ceph-conf",
                        mountPath: "/etc/ceph",
                     },
                     {
                        name: "key-conf",
                        mountPath: "/etc/ceph-metrics/key-config",
                        readOnly: true,
                     },
                     {
                        name: "ceph-cluster-conf",
                        mountPath: "/etc/ceph-metrics/ceph-cluster-config",
                        readOnly: true,
                     },
                     {
                        name: "kubernetes",
                        mountPath: "/etc/kubernetes",
                     },
                  ],
               },
            ],
         },
      },
   },
} else if configs.estate == "prd-sam_storage" then
   {
      apiVersion: "v1",
      kind: "List",
      metadata: {},
      items: [
         {
            local escapedMinionEstate = storageutils.string_replace(minionEstate, "_", "-"),
            local cephClusterName = "ceph-" + escapedMinionEstate,
            local cephClusterNamespace = (if configs.estate == "prd-sam_storage" then cephClusterName else "legostore"),

            apiVersion: "extensions/v1beta1",
            kind: "Deployment",
            metadata: {
               name: "ceph-metrics",
               namespace: cephClusterNamespace,
               labels: {
                  team: "legostore",
                  cloud: "storage",
               },
            },
            spec: {
               replicas: 1,
               template: {
                  metadata: {
                     labels: {
                        app: "ceph-metrics",
                        team: "legostore",
                        cloud: "storage",
                     },
                  },
                  spec: {
                     nodeSelector: {
                     } +
                     if configs.estate == "phx-sam" then {
                           pool: configs.estate,
                     } else {
                           pool: storageconfigs.cephMetricsPool,
                     },
                     volumes: [
                        {
                           name: "kubernetes",
                           hostPath: {
                              path: "/etc/kubernetes",
                           },
                        },
                        {
                           name: "ceph-conf",
                           emptyDir: {},
                        },
                        {
                           name: "key-conf",
                           secret: {
                              secretName: "ceph-client-key",
                           },
                        },
                        {
                           name: "ceph-cluster-conf",
                           configMap: {
                              name: "ceph-cluster",
                           },
                        },
                     ],
                     containers: [
                        {
                           name: "sfms",
                           image: storageimages.sfms,
                           imagePullPolicy: "IfNotPresent",
                           command: [
                              "/opt/sfms/bin/sfms",
                           ],
                           args: [
                              "-m",
                              "snapshot_for_cephmon",
                              "-t",
                              "ajna_with_tags",
                              "-s",
                              "cephmon",
                              "-i",
                              '60',
                           ],
                           ports: [
                              {
                                 name: "ceph-metrics",
                                 containerPort: 8001,
                                 protocol: "TCP",
                              },
                           ],
                           volumeMounts: [
                              {
                                 name: "ceph-conf",
                                 mountPath: "/etc/ceph",
                              },
                           ],
                           env: storageutils.sfms_environment_vars("ceph"),
                        },
                        {
                           name: "configwatcher",
                           image: storageimages.configwatcher,
                           args: [
                              "-ceph-key-config-dir=/etc/ceph-metrics/key-config",
                              "-ceph-cluster-config-dir=/etc/ceph-metrics/ceph-cluster-config",
                              "-ceph-config-dir=/etc/ceph",
                           ],
                           volumeMounts: [
                              {
                                 name: "ceph-conf",
                                 mountPath: "/etc/ceph",
                              },
                              {
                                 name: "key-conf",
                                 mountPath: "/etc/ceph-metrics/key-config",
                                 readOnly: true,
                              },
                              {
                                 name: "ceph-cluster-conf",
                                 mountPath: "/etc/ceph-metrics/ceph-cluster-config",
                                 readOnly: true,
                              },
                              {
                                 name: "kubernetes",
                                 mountPath: "/etc/kubernetes",
                              },
                           ],
                        },
                     ],
                  },
               },
            },
         }
         for minionEstate in storageconfigs.cephEstates[configs.estate]
      ],
   }
else "SKIP"
