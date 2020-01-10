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
        # override in minimal prod estate to get image into prod for PCL canary testing.
        "frf,frf-sam,sdn-vault-agent,hypersdn": "2296-b9f375d9fd1c89fbb591b1eb4cc75979a2205c43",
    },

    ### Per-phase image tags
    per_phase: {

        ### Release Phase 1 - prd-sdc, xrd-sdc
        "1": {
            hypersdn: "2296-b9f375d9fd1c89fbb591b1eb4cc75979a2205c43",
            sitebridge: "878-190c1fe926f8e03a212d8a0ca922140018530ad0",
            bird: "510-089d973608446c4ee24e8ee0013d10620f61566c",
            hyperelk: "v-0000102-91c9122c",
            },

        ### Release Phase 2 - PRD-SAMTEST/PRD-SAMDEV/PRD-DATA-FLOWSNAKE-TEST
        "2": {
            hypersdn: "2296-b9f375d9fd1c89fbb591b1eb4cc75979a2205c43",
            bird: "510-089d973608446c4ee24e8ee0013d10620f61566c",
            hyperelk: "v-0000102-91c9122c",
            },

        ### Release Phase 3 - Rest of the SAM clusters in PRD
        "3": {
            hypersdn: "2235-f72e41190116a32729ba81003ba6754f4f4796c8",
            bird: "503-94b968cf67a338280f71a5c932f0956d13e982bb",
            hyperelk: "v-0000102-91c9122c",
            elkagents: "v-0000818-072ffbb4",
            },

        ### Release Phase 4 - Canary sites in Prod
        "4": {
            hypersdn: "2235-f72e41190116a32729ba81003ba6754f4f4796c8",
            bird: "503-94b968cf67a338280f71a5c932f0956d13e982bb",
            hyperelk: "v-0000102-91c9122c",
            },

        ### Release Phase 5 - All Prod
        "5": {
            hypersdn: "2235-f72e41190116a32729ba81003ba6754f4f4796c8",
            bird: "503-94b968cf67a338280f71a5c932f0956d13e982bb",
            hyperelk: "v-0000102-91c9122c",
            },
    },

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-sdc") || (estate == "xrd-sdc") then
            "1"
        else if (estate == "prd-samtest") || (estate == "prd-samdev") || (estate == "prd-data-flowsnake_test") then
            "2"
        else if (kingdom == "prd") then
            "3"
        else if (kingdom == "frf") || (kingdom == "fra") then
            "4"
        else
            "5"
        ),

    # ====== ONLY CHANGE THE STUFF BELOW WHEN ADDING A NEW IMAGE.  RELEASES SHOULD ONLY INVOLVE CHANGES ABOVE ======

    # These are the images used by the templates
    hypersdn: imageFunc.do_override_for_pipeline_image($.overrides, "sdn", "hypersdn", $.per_phase[$.phase].hypersdn),
    sitebridge: imageFunc.do_override_for_pipeline_image($.overrides, "sdn", "sitebridge", $.per_phase[$.phase].sitebridge),
    bird: imageFunc.do_override_for_pipeline_image($.overrides, "sdn", "bird", $.per_phase[$.phase].bird),
    hyperelk: imageFunc.do_override_for_pipeline_image($.overrides, "sdn", "hyperelk", $.per_phase[$.phase].hyperelk),
    elkagents: imageFunc.do_override_for_pipeline_image($.overrides, "sdn", "hypersdn", $.per_phase[$.phase].elkagents),
    # image_functions needs to know the filename of the template we are processing
    # Each template must set this at time of importing this file, for example:
    #
    # "local someteamimages = (import "someteamimages.jsonnet")  + { templateFilename:: std.thisFile };"
    #
    # Then we pass this again into image_functions at time of import.
    templateFilename:: error "templateFilename must be passed at time of import",
    local imageFunc = (import "image_functions.libsonnet") + { templateFilename:: $.templateFilename },
}
