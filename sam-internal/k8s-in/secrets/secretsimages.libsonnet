local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local utils = import "util_functions.jsonnet";
local secretsconfigs = import "secretsconfig.libsonnet";
local secretsreleases = import "secretsreleases.json";

{
    ### Global overrides - Anything here will override anything below
    overrides: {
        #
        # This section lets you override any secrets image for a given kingdom,estate,template,image.
        # Template is the short name of the template. For k8s-in/templates/samcontrol.jsonnet use "samcontrol"
        # Image name
        #
        # Example:
        #   "prd,prd-sam,samcontrol,hypersam": "sam-0000123-deadbeef",

    },

    ### Per-phase image tags are defined in secretsreleases.jsonnet

    sswatchdogPhase(canary=false): (
        if canary then
            "1"
        else if (estate == "prd-sam" || estate == "xrd-sam") then
            "2"
        else if (kingdom == 'phx' || kingdom == 'dfw') then
            "3"
        else
            "4"
        ),

    k4aSamWatchdogPhase: (
        if (estate == "prd-samtest") then
            "1"
        else if (estate == "prd-sam" || estate == "xrd-sam") then
            "2"
        else if (estate == "phx-sam" || estate == "dfw-sam") then
            "3"
        else
            "4"
    ),

    # These are the images used by the templates
    sswatchdog(canary=false): imageFunc.do_override_for_pipeline_image($.overrides, null, "secretservice-watchdog", secretsreleases[$.sswatchdogPhase(canary)].sswatchdog.label),
    sswatchdog_build(canary=false): imageFunc.build_info_from_tag(secretsreleases[$.sswatchdogPhase(canary)].sswatchdog.label).buildNumber,

    k4aSamWatchdog: imageFunc.do_override_for_pipeline_image($.overrides, "sam", "hypersam", secretsreleases[$.k4aSamWatchdogPhase].k4asamwatchdog.label),
    k4aSamWatchdog_build: imageFunc.build_info_from_tag(secretsreleases[$.k4aSamWatchdogPhase].k4asamwatchdog.label).buildNumber,

    # image_functions needs to know the filename of the template we are processing
    # Each template must set this at time of importing this file, for example:
    #
    # "local someteamimages = (import "someteamimages.jsonnet")  + { templateFilename:: std.thisFile };"
    #
    # Then we pass this again into image_functions at time of import.
    templateFilename:: error "templateFilename must be passed at time of import",
    local imageFunc = (import "image_functions.libsonnet") + { templateFilename:: $.templateFilename },
}
