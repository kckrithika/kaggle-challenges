local configs = import "config.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";
local utils = import "storageutils.jsonnet";
local cephclusterimage = (import "ceph-cluster-image.libsonnet") + { templateFilename:: std.thisFile };
local isEstateNotSkipper = configs.estate != "prd-skipper";

// Defines the list of estates where this service is enabled.
local enabledEstates = std.set([
    "prd-sam",
    "phx-sam",
    "prd-sam_storage",
    "prd-skipper",
]);

if std.setMember(configs.estate, enabledEstates) then
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
                    cephVersion: cephclusterimage.do_cephdaemon_tag_override(minionEstate),
                    faultDomainBoundary: "node.sam.sfdc.net/rack",
                    K8S_NETWORK: storageconfigs.perEstate.ceph.k8s_subnet[configs.estate][minionEstate],
                    storageClassAllocations: [
                        {
                            name: "hdd",
                            aggregateStorage: storageconfigs.perEstate.ceph.aggregateStorage[configs.estate][minionEstate],
                        },
                    ],
                } + if isEstateNotSkipper then { pool: minionEstate } else { cephOsdDaemonOverride: "osd_directory" },
            }
            for minionEstate in storageconfigs.cephEstates[configs.estate]
        ],
    }
else "SKIP"
