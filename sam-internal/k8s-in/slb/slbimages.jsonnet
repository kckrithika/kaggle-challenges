local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local utils = import "util_functions.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbreleases = import "slbreleases.json";

{
    ### Global overrides - Anything here will override anything below
    overrides: {
        #
        # This section lets you override any hyperslb image for a given kingdom,estate,template,image.
        # Template is the short name of the template. For k8s-in/templates/samcontrol.jsonnet use "samcontrol"
        # Image name
        #
        # Example:
        #   "prd,prd-sam,samcontrol,hypersam": "sam-0000123-deadbeef",

    },

    ### Per-phase image tags have been moved to slbreleases.jsonnet

    ### Phase kingdom/estate mapping
    # SLB prod kingdoms: ['frf', 'phx', 'iad', 'ord', 'dfw', 'hnd', 'xrd', 'cdg', 'fra'],
    # SLB prod estates in prd: ['prd-sam', 'prd-samtwo'],
    # SLB testEstates: ['prd-sdc', 'prd-samdev', 'prd-samtest', 'prd-sam_storage'],

    phase: (
        if (estate == "prd-sdc") then
            "1"
        else if slbconfigs.isTestEstate || (estate == "prd-sam") || (estate == "vpod") then
            "2"
        else if (estate == "prd-samtwo" || kingdom in { [k]: 1 for k in ['prd', 'xrd'] }) then
            "3"
        else if kingdom in { [k]: 1 for k in ['phx', 'iad'] } then
            "4"
        else
            "5"
        # else  if kingdom in { [k]: 1 for k in ['cdg', 'dfw', 'ord'] } then
        #     "5"
        # else if kingdom in { [k]: 1 for k in ['fra', 'hnd', 'frf'] } then
        #     "6"
        # else
        #     "7"
        ),

    # ====== ONLY CHANGE THE STUFF BELOW WHEN ADDING A NEW IMAGE.  RELEASES SHOULD ONLY INVOLVE CHANGES ABOVE ======
    phaseNum: std.parseInt($.phase),

    # These are the images used by the templates
    hyperslb: imageFunc.do_override_for_pipeline_image($.overrides, "slb", "hyperslb", slbreleases[$.phase].hyperslb.label),
    hyperslb_build: imageFunc.build_info_from_tag(slbreleases[$.phase].hyperslb.label).buildNumber,

    # An old hypersdn image that should be deployed on all current ipvs nodes.
    # TODO: switch to the sdn image (from sdnimages.jsonnet) once that has been successfully pulled everywhere.
    fixed_hypersdn_bootstrap_tag: "v-0001443-9c651010",
    hypersdn_ipvs_bootstrap: imageFunc.do_override_for_pipeline_image($.overrides, "sdn", "hypersdn", $.fixed_hypersdn_bootstrap_tag),

    slbnginx: imageFunc.do_override_for_pipeline_image($.overrides, "slb", "nginx", slbreleases[$.phase].slbnginx.label),
    slbnginx_build: imageFunc.build_info_from_tag(slbreleases[$.phase].slbnginx.label).buildNumber,

    slbenvoy: imageFunc.do_override_for_pipeline_image($.overrides, "slb", "envoy", slbreleases[$.phase].slbenvoy.label),
    slbenvoy_build: imageFunc.build_info_from_tag(slbreleases[$.phase].slbenvoy.label).buildNumber,

    hsmnginx: imageFunc.do_override_for_pipeline_image($.overrides, "slb", "nginx-kms", slbreleases[$.phase].kmsnginx.label),
    hsmnginx_build: imageFunc.build_info_from_tag(slbreleases[$.phase].kmsnginx.label).buildNumber,

    # image_functions needs to know the filename of the template we are processing
    # Each template must set this at time of importing this file, for example:
    #
    # "local someteamimages = (import "someteamimages.jsonnet")  + { templateFilename:: std.thisFile };"
    #
    # Then we pass this again into image_functions at time of import.
    templateFilename:: error "templateFilename must be passed at time of import",
    local imageFunc = (import "image_functions.libsonnet") + { templateFilename:: $.templateFilename },
}
