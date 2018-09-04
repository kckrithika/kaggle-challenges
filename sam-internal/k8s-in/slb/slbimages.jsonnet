# kick
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local utils = import "util_functions.jsonnet";
local slbconfig = import "slbconfig.jsonnet";
local slbreleases = import "slbreleases.json";

{
    ### Global overrides - Anything here will override anything below
    overrides: {
        #
        # This section lets you override any hypersdn image for a given kingdom,estate,template,image.
        # Template is the short name of the template. For k8s-in/templates/samcontrol.jsonnet use "samcontrol"
        # Image name
        #
        # Example:
        #   "prd,prd-sam,samcontrol,hypersam": "sam-0000123-deadbeef",

    },

    ### Per-phase image tags have been moved to slbreleases.jsonnet

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-sdc") then
            "1"
        else if kingdom in { [k]: 1 for k in ['prd'] } then
            "2"
        else if kingdom in { [k]: 1 for k in ['phx', 'iad', 'xrd'] } then
            "3"
        else if kingdom in { [k]: 1 for k in ['cdg', 'fra'] } then
            "1"
        else
            "4"
        ),

    # ====== ONLY CHANGE THE STUFF BELOW WHEN ADDING A NEW IMAGE.  RELEASES SHOULD ONLY INVOLVE CHANGES ABOVE ======
    phaseNum: std.parseInt($.phase),

    # These are the images used by the templates
    hypersdn: imageFunc.do_override_for_tnrp_image($.overrides, "sdn", "hypersdn", slbreleases[$.phase].hypersdn.label),
    hypersdn_build: std.parseInt(std.split(slbreleases[$.phase].hypersdn.label, "-")[1]),

    slbnginx: imageFunc.do_override_for_tnrp_image($.overrides, "sdn", "slb-nginx", slbreleases[$.phase].slbnginx.label),
    slbnginx_build: std.parseInt(std.split(slbreleases[$.phase].slbnginx.label, "-")[1]),

    # image_functions needs to know the filename of the template we are processing
    # Each template must set this at time of importing this file, for example:
    #
    # "local someteamimages = (import "someteamimages.jsonnet")  + { templateFilename:: std.thisFile };"
    #
    # Then we pass this again into image_functions at time of import.
    templateFilename:: error "templateFilename must be passed at time of import",
    local imageFunc = (import "image_functions.libsonnet") + { templateFilename:: $.templateFilename },
}
