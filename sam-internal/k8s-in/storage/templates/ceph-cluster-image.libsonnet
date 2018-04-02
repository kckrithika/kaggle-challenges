local utils = import "storageutils.jsonnet";

// Public functions.
{
    # Utility function to look up the ceph daemon image tag for the supplied minion estate, applying any overrides from storageimages.jsonnet.
    do_cephdaemon_tag_override(minionEstate):: (
        utils.do_minion_estate_tag_override(storageimages.overrides, minionEstate, "ceph-cluster", "ceph-daemon", storageimages.cephdaemon_tag)
    ),

    # Utility function to look up the ceph daemon full image path for the supplied minion estate, applying any overrides from storageimages.jsonnet.
    do_cephdaemon_image_override(minionEstate):: (
        local tag = $.do_cephdaemon_tag_override(minionEstate);
        imageFunc.do_override_based_on_tag(storageimages.overrides, "storagecloud", "ceph-daemon", tag)
    ),

    templateFilename:: error "templateFilename must be passed at time of import",
    local imageFunc = (import "image_functions.libsonnet") + { templateFilename:: $.templateFilename },
    local storageimages = (import "storageimages.jsonnet") + { templateFilename:: $.templateFilename },
}