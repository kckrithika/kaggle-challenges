local configs = import "config.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" || configs.estate == "phx-sam" then {
   apiVersion: "v1",
   kind: "Service",
   metadata: {
      name: "ceph-metrics",
      namespace: storageconfigs.cephMetricsNamespace,
      labels: {
         app: "ceph-metrics",
         team: "legostore",
         cloud: "storage",
      },
      annotations: {
         "slb.sfdc.net/name": "ceph-metrics",
         "slb.sfdc.net/portconfigurations": '[{"port":8001,"targetport":8001,"lbtype":"tcp"}]',
      },
   },
   spec: {
      ports: [
         {
            name: "ceph-metrics",
            port: 8001,
            protocol: "TCP",
            targetPort: 8001,
            nodePort: 38001,
         },
      ],
      selector: {
         app: "ceph-metrics",
      },
      type: "NodePort",
   },
} else "SKIP"
