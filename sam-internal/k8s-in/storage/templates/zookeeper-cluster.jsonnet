local configs = import "config.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";
local utils = import "storageutils.jsonnet";

if configs.estate == "prd-sam_storagedev" then
    {
        apiVersion: "v1",
        kind: "List",
        metadata: {},
        items: [
            {
                local escapedMinionEstate = utils.string_replace(minionEstate, "_", "-"),
                local zookeeperClusterName = "sfn-zk",  // Alternatively, this could come from per-estate config.
                local zookeeperClusterNamespace = "zookeeper",  // Alternatively, this could come from per-estate config.

                kind: "ZkCluster",
                apiVersion: "storage.salesforce.com/v1beta1",
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
                    aggregateStorage: storageconfigs.perEstate.zookeeper.replicas[minionEstate],
                },
            }
            for minionEstate in storageconfigs.zookeeperEstates[configs.estate]
        ],
    }
else "SKIP"
