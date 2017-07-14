local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local utils = import "util_functions.jsonnet";
{
    # ================== SAM RELEASE ====================
    # Releases should follow the order below unless there are special circumstances.  Each phase should use the
    # image from the previous stage after a 24 hour bake time with no issues (check that all watchdog are healthy)
    #
    # https://git.soma.salesforce.com/sam/sam/wiki/Deploy-SAM

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

        "prd,prd-sdc,sam-secret-agent,hypersam": "sam-0000901-82ac08ff",
        "prd,prd-samtest,sam-secret-agent,hypersam": "sam-0000901-82ac08ff",
        "prd,prd-sam,watchdog-pullrequest,hypersam": "sam-0001034-070ff746",
    },

    ### Per-phase image tags
    per_phase: {

        ### Release Phase 1 - Test Beds
        "1": {
            "hypersam": "sam-0001027-676096c4",
            },

        ### Release Phase 2 - PRD Sandbox and prd-sdc
        "2": {
            "hypersam": "sam-0001027-676096c4",
            },

        ### Release Phase 3 - Canary Prod FRF
        "3": {
            "hypersam": "sam-0001027-676096c4",
            },

        ### Release Phase 4 - Rest of Prod
        "4": {
            "hypersam": "sam-0001027-676096c4",
            },
    },

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-samdev" || estate == "prd-samtest") then
            "1"
        else if (kingdom == "prd") then
            "2"
        else if (kingdom == "frf" || kingdom == "yhu" || kingdom == "yul") then
            "3"
        else
            "4"
        ),

    # Static images that do not go in phases
    static: {
        "k8sproxy": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/cbatra/haproxy:20170614_183811.a8a02a5.clean.cbatra-ltm1",
        "estate_info": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/yunfan-wang/hypersam:2017.7.14.0",

        "permissionInitContainer": (
            if (kingdom=="prd") then
                "sam-c07d4afb-673"
            else
                "sam-1ebeb0ac-657"
        ),
    },

    # ====== DO NOT EDIT BELOW HERE ======

    # These are the images used by the templates
    hypersam: utils.do_override_for_tnrp_image($.overrides, "sam", "hypersam", $.per_phase[$.phase]["hypersam"]),
    k8sproxy: utils.do_override_for_not_tnrp_image($.overrides, "k8sproxy", $.static["k8sproxy"]),
    estate_info: utils.do_override_for_not_tnrp_image($.overrides, "estate_info", $.static["estate_info"]),
    permissionInitContainer: utils.do_override_for_tnrp_image($.overrides, "sam", "hypersam", $.static["permissionInitContainer"]),

}
