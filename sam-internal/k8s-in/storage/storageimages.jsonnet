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

        ### Release Phase 0 - prd-sam_storage
        "0": {
            default_tag: "base-0000210-ed9ff25c",
            sfms_tag: "latest-0000047-f46de00d",
        },

        ### Release Phase 1 - prd-sdc
        "1": {
            default_tag: "",
            },

        ### Release Phase 2 - Rest of the SAM clusters in PRD
        "2": {
            default_tag: "",
            },

        ### Release Phase 3 - Canary sites in Prod
        "3": {
            default_tag: "",
            },

        ### Release Phase 3 - All Prod
        "4": {
            default_tag: "",
            },
    },

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-sam_storage") then
            "0"
        else if (estate == "prd-sdc") then
            "1"
        else if (kingdom == "prd") then
            "2"
        else if (kingdom == "frf") then
            "3"
        else
            "4"
        ),

    # ====== ONLY CHANGE THE STUFF BELOW WHEN ADDING A NEW IMAGE.  RELEASES SHOULD ONLY INVOLVE CHANGES ABOVE ======

    # These are the images used by the templates.
    fdscontroller: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "faultdomainset", $.per_phase[$.phase].default_tag),
    configwatcher: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "configwatcher", $.per_phase[$.phase].default_tag),
    sfms: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "sfms", $.per_phase[$.phase].sfms_tag),
    sfstore: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "sfstoreoperator", $.per_phase[$.phase].default_tag),
    ceph: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "ceph", $.per_phase[$.phase].default_tag),
}
