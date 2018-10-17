local configs = import "config.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";
local utils = import "storageutils.jsonnet";
local commonutils = import "util_functions.jsonnet";

if configs.estate == "prd-sam_storagedev" then
    {
        apiVersion: "v1",
        kind: "List",
        metadata: {},
        items: [
            {
                local escapedMinionEstate = commonutils.string_replace(minionEstate, "_", "-"),
                local zookeeperClusterName = "sfn-zk",  // Alternatively, this could come from per-estate config.
                local zookeeperClusterNamespace = "zookeeper",  // Alternatively, this could come from per-estate config.

                kind: "ZkCluster",
                apiVersion: "storage.salesforce.com/v1",
                metadata: {
                    name: zookeeperClusterName,
                    namespace: zookeeperClusterNamespace,
                    annotations: {
                        "manifestctl.sam.data.sfdc.net/swagger": "disable",
                    },
                },
                spec: {
                    version: storageconfigs.perEstate.zookeeper.version[minionEstate],
                    faultDomainBoundary: storageconfigs.perEstate.zookeeper.boundary[minionEstate],
                    replicas: storageconfigs.perEstate.zookeeper.replicas[minionEstate],
                },
            }
            for minionEstate in storageconfigs.zookeeperEstates[configs.estate]
        ],
    }
else "SKIP"
