local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local utils = import "util_functions.jsonnet";
{
    ### Global overrides - Anything here will override anything below
    overrides: {
        #
        # This section lets you override any hypersam image for a given kingdom,estate,template,image.
        # Template is the short name of the template.  For k8s-in/templates/samcontrol.jsonnet use "samcontrol"
        # Image name
        #
        # Example:
        #   "prd,prd-sam,samcontrol,hypersam": "sam-0000123-deadbeef",
        #
        # override sam-storage temporarily
    },

    ### Per-phase image tags
    per_phase: {

        ### Release Phase 1 - prd-sdc
        "1": {
            hypersdn: "v-0000394-4e124105",
            bird: "v-0000014-b0a5951d",
            },

        ### Release Phase 2 - Rest of the SAM clusters in PRD
        "2": {
            hypersdn: "v-0000394-4e124105",
            bird: "v-0000014-b0a5951d",
            },

        ### Release Phase 3 - Canary sites in Prod
        "3": {
            hypersdn: "v-0000394-4e124105",
            bird: "v-0000014-b0a5951d",
            },

        ### Release Phase 4 - All Prod
        "4": {
            hypersdn: "v-0000371-76a3b283",
            bird: "v-0000014-b0a5951d",
            },
    },

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-sdc") then
            "1"
        else if (kingdom == "prd") then
            "2"
        else if (kingdom == "frf") then
            "3"
        else
            "4"
        ),

    # ====== ONLY CHANGE THE STUFF BELOW WHEN ADDING A NEW IMAGE.  RELEASES SHOULD ONLY INVOLVE CHANGES ABOVE ======

    # These are the images used by the templates
    hypersdn: utils.do_override_for_tnrp_image($.overrides, "sdn", "hypersdn", $.per_phase[$.phase].hypersdn),
    bird: utils.do_override_for_tnrp_image($.overrides, "sdn", "bird", $.per_phase[$.phase].bird),
}
