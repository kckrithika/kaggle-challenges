local configs = import "config.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";
local utils = import "storageutils.jsonnet";

// Disable sfstore cluster manifest in prd-sam_storage for now.
if configs.estate == "TODO: prd-sam_storage" then
    {
        apiVersion: "v1",
        kind: "List",
        metadata: {},
        items: [
            {
                local escapedMinionEstate = utils.string_replace(minionEstate, "_", "-"),
                local sfstoreClusterName = "prdsam",  // Alternatively, this could come from per-estate config.
                local sfstoreClusterNamespace = "sfstore",  // Alternatively, this could come from per-estate config.

                kind: "SfstoreCluster",
                apiVersion: "sfstore.storage.salesforce.com/v1beta1",
                metadata: {
                    name: sfstoreClusterName,
                    namespace: sfstoreClusterNamespace,
                    annotations: {
                        "manifestctl.sam.data.sfdc.net/swagger": "disable",
                    },
                },
                spec: {
                    pool: minionEstate,
                    version: storageconfigs.perEstate.sfstore.version[minionEstate],
                    faultDomainBoundary: storageconfigs.perEstate.sfstore.boundary[minionEstate],
                    aggregateStorage: storageconfigs.perEstate.sfstore.aggregateStorage[minionEstate],
                },
            }
            for minionEstate in storageconfigs.sfstoreEstates[configs.estate]
        ],
    }
else "SKIP"
