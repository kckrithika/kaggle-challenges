local configs = import "config.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";
local utils = import "storageutils.jsonnet";

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" then
    {
        apiVersion: "v1",
        kind: "List",
        metadata: {},
        items: [
            {
                local escapedMinionEstate = utils.string_replace(minionEstate, "_", "-"),
                local cephClusterName = "ceph-" + escapedMinionEstate,

                // TODO: In prd-sam, RBAC rules prevent pods from running if they are created in a namespace other than `legostore`
                //       or `storage-foundation`. Use the `legostore` namespace for now.
                local cephClusterNamespace = (if minionEstate == "prd-sam_ceph" then "legostore" else cephClusterName),

                kind: "CephCluster",
                apiVersion: "storage.salesforce.com/v1beta1",
                metadata: {
                    name: cephClusterName,
                    namespace: cephClusterNamespace,
                    annotations: {
                        "manifestctl.sam.data.sfdc.net/swagger": "disable",
                    },
                },
                spec: {
                    metadata: {
                        name: cephClusterName,
                        namespace: cephClusterNamespace,
                    },
                    pool: minionEstate,
                    cephVersion: "latest",
                    faultDomainBoundary: "node.sam.sfdc.net/rack",
                    K8S_NETWORK: storageconfigs.perEstate.ceph.k8s_subnet[configs.estate][minionEstate],
                    storageClassAllocations: [
                        {
                            name: "hdd",
                            aggregateStorage: storageconfigs.perEstate.ceph.aggregateStorage[configs.estate][minionEstate],
                        },
                    ],
                },
            }
            for minionEstate in storageconfigs.cephEstates[configs.estate]
        ],
    }
else "SKIP"
