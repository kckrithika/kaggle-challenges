local configs = import "config.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";
local utils = import "storageutils.jsonnet";

if configs.estate == "phx-sam" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" then
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
                    "slb.sfdc.net/name": storageconfigs.serviceDefn.ceph_metrics_svc.name,
                    "slb.sfdc.net/portconfigurations": "[{%(port1)s}]" % {
                        port1: storageconfigs.serviceDefn.ceph_metrics_svc.health["port-config"],
                    },
               },
            },
            spec: {
               ports: [
                  {
                     name: storageconfigs.serviceDefn.ceph_metrics_svc.health["port-name"],
                     port: storageconfigs.serviceDefn.ceph_metrics_svc.health.port,
                     protocol: "TCP",
                     targetPort: storageconfigs.serviceDefn.ceph_metrics_svc.health.port,
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
