local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
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

        # [agajjala] Rolling out latest image of hypersdn to CDU with sdn-aws-controller
        "cdu,cdu-sam,sdn-aws-controller,hypersdn": "v-0000646-7aa86116",

    },

    ### Per-phase image tags
    per_phase: {

        ### Release Phase 1 - prd-sdc
        "1": {
            hypersdn: "v-0000640-2e73cf4c",
            bird: "v-0000016-a0f26f27",
            },

        ### Release Phase 2 - PRD-SAMTEST/PRD-SAMDEV/PRD-DATA-FLOWSNAKE-TEST
        "2": {
            hypersdn: "v-0000621-9ceb3d47",
            bird: "v-0000014-b0a5951d",
            },

        ### Release Phase 3 - Rest of the SAM clusters in PRD
        "3": {
            hypersdn: "v-0000621-9ceb3d47",
            bird: "v-0000014-b0a5951d",
            },

        ### Release Phase 4 - Canary sites in Prod
        "4": {
            hypersdn: "v-0000621-9ceb3d47",
            bird: "v-0000014-b0a5951d",
            },

        ### Release Phase 5 - All Prod
        "5": {
            hypersdn: "v-0000580-b84ce00f",
            bird: "v-0000014-b0a5951d",
            },
    },

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-sdc") then
            "1"
        else if (estate == "prd-samtest") || (estate == "prd-samdev") || (estate == "prd-data-flowsnake_test") then
            "2"
        else if (kingdom == "prd") then
            "3"
        else if (kingdom == "frf") then
            "4"
        else
            "5"
        ),

    # ====== ONLY CHANGE THE STUFF BELOW WHEN ADDING A NEW IMAGE.  RELEASES SHOULD ONLY INVOLVE CHANGES ABOVE ======

    # These are the images used by the templates
    hypersdn: imageFunc.do_override_for_tnrp_image($.overrides, "sdn", "hypersdn", $.per_phase[$.phase].hypersdn),
    bird: imageFunc.do_override_for_tnrp_image($.overrides, "sdn", "bird", $.per_phase[$.phase].bird),

    # image_functions needs to know the filename of the template we are processing
    # Each template must set this at time of importing this file, for example:
    #
    # "local someteamimages = (import "someteamimages.jsonnet")  + { templateFilename:: std.thisFile };"
    #
    # Then we pass this again into image_functions at time of import.
    templateFilename:: error "templateFilename must be passed at time of import",
    local imageFunc = (import "image_functions.libsonnet") + { templateFilename:: $.templateFilename },
}
