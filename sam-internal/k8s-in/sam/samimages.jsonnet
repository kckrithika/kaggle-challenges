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

        # [cbatra] Trying out working K4A
        "prd,prd-samtest,samcontrol,hypersam": "sam-0001414-0ccb82f3",

        # [thargrove] This build of autodeployer has timeout changed from 1s to 30s
        "prd,prd-samtest,samcontrol-deployer,hypersam": "sam-0001419-636a3f7d",
        "prd,prd-samdev,samcontrol-deployer,hypersam": "sam-0001419-636a3f7d",
        "prd,prd-sam,samcontrol-deployer,hypersam": "sam-0001419-636a3f7d",

        # [prabhs] Synthetic Timeout increased from 30s to 300s
        "prd,prd-samtest,watchdog-synthetic,hypersam": "sam-0001423-ee310fbc",
        "prd,prd-samdev,watchdog-synthetic,hypersam": "sam-0001423-ee310fbc",
        "prd,prd-sam,watchdog-synthetic,hypersam": "sam-0001423-ee310fbc",
    },

    ### This section list private build overrides that can be deployed to the test clusters
    # for temporary testing
    # While doing a new release this should be set to empty to deploy the official build
    #
    privatebuildoverridetag: "",


    ### Per-phase image tags
    per_phase: {

        ### Release Phase 1 - Test Beds
        # See https://git.soma.salesforce.com/sam/sam/wiki/Deploy-SAM on how to quickly find latest image
        # When rolling this phase, remove all overrides from test beds above
        # Make sure there are no critical watchdogs firing before/after the release, and check SAMCD emails to make sure all rolled properly
        "1": {
            hypersam: "sam-0001408-441a28db",
            madkub: "1.0.0-0000042-8cf4deae",
            madkubSidecar: "1.0.0-0000042-8cf4deae",
            },

        ### Release Phase 2 - PRD Sandbox and prd-sdc
        "2": {
            hypersam: "sam-0001408-441a28db",
            madkub: "1.0.0-0000041-d903c148",
            madkubSidecar: "1.0.0-0000041-d903c148",
            },

        ### Release Phase 3 - Canary Prod FRF and public-cloud
        "3": {
            hypersam: "sam-0001355-581a778b",
            madkub: "1.0.0-0000035-9241ed31",
            madkubSidecar: "1.0.0-0000035-9241ed31",
            },


        ### Release Phase 4 - Rest of Prod
        "4": {
            hypersam: "sam-0001355-581a778b",
            madkub: "1.0.0-0000035-9241ed31",
            madkubSidecar: "1.0.0-0000035-9241ed31",
            },

       ### For testing private bits from a developer's machine pre-checkin if
       ### privatebuildoverride overrides are defined, otherwise use phase 1
       privates: {
           hypersam: (
             if ($.privatebuildoverridetag != "") then
                $.privatebuildoverridetag
             else $.per_phase["1"].hypersam
),
           madkub: $.per_phase["1"].madkub,
           madkubSidecar: $.per_phase["1"].madkubSidecar,
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
        else if (kingdom == "frf" || kingdom == "yhu") then
            "3"
        else
            "4"
        ),

    # Static images that do not go in phases
    static: {
        k8sproxy: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/cbatra/haproxy:20170614_183811.a8a02a5.clean.cbatra-ltm1",

        permissionInitContainer: (
            if (kingdom == "prd") then
                "sam-c07d4afb-673"
            else
                "sam-1ebeb0ac-657"
        ),
    },

    # ====== DO NOT EDIT BELOW HERE ======

    # These are the images used by the templates
    hypersam: utils.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].hypersam),
    k8sproxy: utils.do_override_based_on_tag($.overrides, "sam", "k8sproxy", $.static.k8sproxy),
    permissionInitContainer: utils.do_override_based_on_tag($.overrides, "sam", "hypersam", $.static.permissionInitContainer),

    #Image to use for k4a. Will change to appropiate tags later.
    k4aInitContainerImage: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/cbatra/k4a:1028",
    # madkub is for the server, the sidecar is for the injected containers. They are different because hte injected force a restart
    # of all containers
    madkub: utils.do_override_based_on_tag($.overrides, "sam", "madkub", $.per_phase[$.phase].madkub),

    # For now we pass the image and registry separately. so not doing overrides.
    #madkubSidecar: utils.do_override_based_on_tag($.overrides, "sam", "madkub", $.per_phase[$.phase].madkubSidecar),
    madkubSidecar: "sam/madkub:" + $.per_phase[$.phase].madkubSidecar,
}
