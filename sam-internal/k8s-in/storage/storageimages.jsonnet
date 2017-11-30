local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local utils = import "util_functions.jsonnet";
{
    ### Global overrides - Anything here will override anything below.
    overrides: {
        #
        # This section lets you override any storage image for a given kingdom,estate,template,image.
        # Template is the short name of the template. For k8s-in/storage/templates/fds-deployment.jsonnet use "fds-deployment"
        # Image name
        #
        # Example:
        #   "prd,prd-sam_storage,fds-deployment,fdscontroller": "faultdomainset-0000123-deadbeef",
        #

    },

    ### Per-phase image tags
    per_phase: {

        ### Release Phase 0 - prd-sam_storage (control plane), prd-sam_cephdev, and prd-sam_sfstoredev
        "0": {
            default_tag: "base-0000251-12e872ba",
            sfms_tag: "latest-0000082-2e9cb777",
            cephdaemon_tag: "jewel-0000047-859f50b7",
            sfstorebookie_tag: "base-0000021-f9f2ef07",
        },

        ### Release Phase 1 - prd-sam (control plane), prd-sam_ceph and prd-sam_sfstore
        "1": {
            default_tag: "base-0000251-12e872ba",
            sfms_tag: "latest-0000082-2e9cb777",
            cephdaemon_tag: "jewel-0000047-859f50b7",
            sfstorebookie_tag: "base-0000021-f9f2ef07",
            },

        ### Release Phase 2 - TBD
        "2": {
            default_tag: "",
            sfms_tag: "latest-0000082-2e9cb777",
            cephdaemon_tag: "jewel-0000047-859f50b7",
            sfstorebookie_tag: "base-0000021-f9f2ef07",
            },

        ### Release Phase 3 - Canary sites in Prod
        "3": {
            default_tag: "",
            cephdaemon_tag: "jewel-0000047-859f50b7",
            sfstorebookie_tag: "base-0000021-f9f2ef07",
            },

        ### Release Phase 4 - All Prod
        "4": {
            default_tag: "",
            },
    },

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-sam_storage" || estate == "prd-sam_cephdev" || estate == "prd-sam_sfstoredev") then
            "0"
        else if (estate == "prd-sam" || estate == "prd-sam_ceph" || estate == "prd-sam_sfstore") then
            "1"
        else if (kingdom == "prd") then
            "2"
        else if (kingdom == "phx") then
            "3"
        else
            "4"
        ),

    # ====== ONLY CHANGE THE STUFF BELOW WHEN ADDING A NEW IMAGE.  RELEASES SHOULD ONLY INVOLVE CHANGES ABOVE ======

    # These are the images used by the templates.

    # Maintained in https://git.soma.salesforce.com/SFStorage/foundation repo.
    fdscontroller: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "faultdomainset", $.per_phase[$.phase].default_tag),
    configwatcher: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "configwatcher", $.per_phase[$.phase].default_tag),
    sfstoreoperator: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "sfstoreoperator", $.per_phase[$.phase].default_tag),
    # TODO(rohit.shekhar) change ceph to cephoperator in foundation codebase, then update ceph below to be cephoperator
    cephoperator: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "ceph", $.per_phase[$.phase].default_tag),
    loginit: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "loginitcontainer", $.per_phase[$.phase].default_tag),

    # The Metric Streamer is maintained in https://git.soma.salesforce.com/SdbStoreOps/Prod-Operations repo. Therefore, it does not use the default_tag.
    sfms: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "sfms", $.per_phase[$.phase].sfms_tag),

    # The ceph daemon image is maintained in the https://git.soma.salesforce.com/SFStorage/ceph-docker repo.
    cephdaemon: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "ceph-daemon", $.per_phase[$.phase].cephdaemon_tag),

    # The sfstore bookie image is maintained in the https://git.soma.salesforce.com/SFStorage/bookkeeper repo.
    sfstorebookie: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "bookie", $.per_phase[$.phase].sfstorebookie_tag),
}
