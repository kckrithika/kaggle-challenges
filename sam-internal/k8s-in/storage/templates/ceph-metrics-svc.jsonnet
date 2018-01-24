local configs = import "config.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";
local utils = import "storageutils.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "phx-sam" then {
   apiVersion: "v1",
   kind: "Service",
   metadata: {
      name: "ceph-metrics",
      namespace: "legostore",
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
} else if configs.estate == "prd-sam_storage" then
   {
      apiVersion: "v1",
      kind: "List",
      metadata: {},
      items: [
         {
            local escapedMinionEstate = utils.string_replace(minionEstate, "_", "-"),
            local cephClusterName = "ceph-" + escapedMinionEstate,
            local cephClusterNamespace = (if configs.estate == "prd-sam_storage" then cephClusterName else "legostore"),

            kind: "Service",
            apiVersion: "v1",
            metadata: {
               name: "ceph-metrics",
               namespace: cephClusterNamespace,
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
                  },
               ],
               selector: {
                  app: "ceph-metrics",
               },
               type: "NodePort",
            },
         }
         for minionEstate in storageconfigs.cephEstates[configs.estate]
      ],
   }
else "SKIP"
