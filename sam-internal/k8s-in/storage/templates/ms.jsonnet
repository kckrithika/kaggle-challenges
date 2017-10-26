local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";

if configs.estate == "prd-sam_storage" then {
   apiVersion: "extensions/v1beta1",
   kind: "Deployment",
   metadata: {
      name: "metric-streamer",
   },
   spec: {
      replicas: 1,
      template: {
         metadata: {
            labels: {
               app: "metric-streamer",
            },
         },
         spec: {
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
                  image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/foundation/sfms-image:latest",
                  imagePullPolicy: "IfNotPresent",
                  command: [
                     "/opt/sfms/bin/sfms",
                  ],
                  args: [
                     "-m",
                     "snapshot_for_cephmon",
                     "-t",
                     "prometheus",
                     "-s",
                     "cephmon",
                     "-i",
                     '10',
                  ],
                  ports: [
                     {
                        name: "http-metrics",
                        containerPort: 8001,
                        protocol: "TCP",
                     },
                  ],
                  livenessProbe: {
                     httpGet: {
                        path: "/healthz",
                           port: 8001,
                     },
                  },
                  volumeMounts: [
                     {
                        name: "ceph-conf",
                        mountPath: "/etc/ceph",
                     },
                  ],
               },
               {
                  name: "configwatcher",
                  image: storageimages.configwatcher,
                  args: [
                     "-key-config-dir=/etc/metric-streamer/key-config",
                     "-ceph-cluster-config-dir=/etc/metric-streamer/ceph-cluster-config",
                     "-ceph-config-dir=/etc/ceph",
                  ],
                  resources: {
                     requests: {
                        memory: "16Mi",
                        cpu: "50m",
                     },
                     limits: {
                        memory: "32Mi",
                        cpu: "100m",
                     },
                  },
                  volumeMounts: [
                     {
                        name: "ceph-conf",
                        mountPath: "/etc/ceph",
                     },
                     {
                        name: "key-conf",
                        mountPath: "/etc/metric-streamer/key-config",
                        readOnly: true,
                     },
                     {
                        name: "ceph-cluster-conf",
                        mountPath: "/etc/metric-streamer/ceph-cluster-config",
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
