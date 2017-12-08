local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";
local storageutils = import "storageutils.jsonnet";

if configs.estate == "prd-sam_storage" then {
   apiVersion: "extensions/v1beta1",
   kind: "Deployment",
   metadata: {
      name: "ceph-metrics",
      namespace: "ceph-test",
   },
   spec: {
      replicas: 1,
      template: {
         metadata: {
            labels: {
               app: "ceph-metrics",
            },
         },
         spec: {
            nodeSelector: {
            } +
            if configs.estate == "prd-sam" then {
                  master: "true",
            } else {
                  pool: configs.estate,
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
} else "SKIP"
