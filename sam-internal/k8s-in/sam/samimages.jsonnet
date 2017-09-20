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
        "prd,prd-samdev,watchdog-kuberesources,hypersam": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/prahlad.joshi/hypersam:20170919_173325.0831c87.clean.prahladjos-ltm",
        "prd,prd-samdev,watchdog-rbac,hypersam": "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/hypersam:sam-0001270-f52e4116",
        "prd,prd-samtest,watchdog-rbac,hypersam": "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/hypersam:sam-0001270-f52e4116",
        "prd,prd-samtest,watchdog-maddog,hypersam": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/prabh.singh/hypersam:20170919_230658.51e210d.dirty.prabhsingh-ltm5",
        "prd,prd-samdev,watchdog-maddog,hypersam": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/prabh.singh/hypersam:20170919_230658.51e210d.dirty.prabhsingh-ltm5",
    },

    ### This section list private build overrides that can be deployed to the test clusters
    # for temporary testing
    # While doing a new release this should be set to empty to deploy the official build
    #
    privatebuildoverridetag:"",


    ### Per-phase image tags
    per_phase: {

        ### Release Phase 1 - Test Beds
        # See https://git.soma.salesforce.com/sam/sam/wiki/Deploy-SAM on how to quickly find latest image
        # When rolling this phase, remove all overrides from test beds above
        # Make sure there are no critical watchdogs firing before/after the release, and check SAMCD emails to make sure all rolled properly
        "1": {
            "hypersam": "sam-0001263-d5b47592",
            },

        ### Release Phase 2 - PRD Sandbox and prd-sdc
        "2": {
            "hypersam": "sam-0001263-d5b47592",
            },

        ### Release Phase 3 - Canary Prod FRF and public-cloud
        "3": {
            #Retrying PHASE 3 release. Docker image pull failed in frf,yul,yhu 
            "hypersam": "sam-0001263-d5b47592",
            },


        ### Release Phase 4 - Rest of Prod
        "4": {
            "hypersam": "sam-0001210-ef6a180b",
            },

       ### For testing private bits from a developer's machine pre-checkin if
       ### privatebuildoverride overrides are defined, otherwise use phase 1
       "privates": {
           "hypersam": (
             if ($.privatebuildoverridetag != "") then
                $.privatebuildoverridetag
             else $.per_phase["1"]["hypersam"]),
           },
    },

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-samtest") then
            "privates"
        else if (estate == "prd-samdev") then
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

        "permissionInitContainer": (
            if (kingdom=="prd") then
                "sam-c07d4afb-673"
            else
                "sam-1ebeb0ac-657"
        ),
    },

    # ====== DO NOT EDIT BELOW HERE ======

    # These are the images used by the templates
    hypersam: utils.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase]["hypersam"]),
    k8sproxy: utils.do_override_based_on_tag($.overrides, "sam", "k8sproxy", $.static["k8sproxy"]),
    permissionInitContainer: utils.do_override_based_on_tag($.overrides, "sam", "hypersam", $.static["permissionInitContainer"]),
}
