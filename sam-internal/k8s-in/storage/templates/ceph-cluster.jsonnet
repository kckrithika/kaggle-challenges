local configs = import "config.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";
local storageimages = (import "storageimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "storageutils.jsonnet";

local internal = {
    # Check for an image override based on kingdom,minionEstate,ceph-cluster,ceph-daemon. If not found return default_tag.
    # This is based on the `do_override` function in util_functions.jsonnet, and allows for ceph cluster override specifications
    # that are consistent with other image overrides.
    #
    # overrides - a map of "kingdom,estate,template,image" to "tag"
    # minionEstate - the estate where the ceph cluster will be created.
    # default_tag - the docker tag to use when no override is found (e.g., "jewel-0000052-36e8b39d")
    #
    do_cephdaemon_tag_override(overrides, minionEstate, default_tag):: (
        local overrideName = configs.kingdom + "," + minionEstate + ",ceph-cluster,ceph-daemon";
        if (std.objectHas(overrides, overrideName)) then
            overrides[overrideName]
        else
            default_tag
    ),
};

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" || configs.estate == "phx-sam" || configs.estate == "prd-skipper" then
    {
        apiVersion: "v1",
        kind: "List",
        metadata: {},
        items: [
            {
                local escapedMinionEstate = utils.string_replace(minionEstate, "_", "-"),
                local cephClusterName = "ceph-" + escapedMinionEstate,

                // TODO: In prd-sam_storage, multiple ceph clusters are defined. Other control estates only use one ceph cluster for
                // now, and RBAC rules in those estates require the cluster to be in the legostore namespace.
                local cephClusterNamespace = (if configs.estate == "prd-sam_storage" then cephClusterName else "legostore"),

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
                    cephVersion: internal.do_cephdaemon_tag_override(storageimages.overrides, minionEstate, storageimages.cephdaemon_tag),
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
