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

        # [diana.chang] Testing daily deployer and setting the 'auto' keyword for particular resources
        "prd,prd-samtest,samcontrol-deployer,hypersam": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/diana.chang/hypersam:20180131_120948.f6eacc29.dirty.dianachang-ltm1",
        "prd,prd-samtest,watchdog-sdp,hypersam": "auto",

        # [hari.udhayakumar] Rolling out latest image of watchdog-kuberesources to all kingdoms. This stops spamming customers and publishes metrics to the correct scope.
        "cdu,cdu-sam,watchdog-kuberesources,hypersam": "sam-0001572-b2f60f37",
        "syd,syd-sam,watchdog-kuberesources,hypersam": "sam-0001572-b2f60f37",
        "yhu,yhu-sam,watchdog-kuberesources,hypersam": "sam-0001572-b2f60f37",
        "yul,yul-sam,watchdog-kuberesources,hypersam": "sam-0001572-b2f60f37",

        # [prabh.singh] Rolling out latest image of watchdog-hairpindeployer to all kingdoms. This will correctly deploy hairpin watchdogs with correct role info.
        "cdu,cdu-sam,watchdog-hairpindeployer,hypersam": "sam-0001568-53c1b42b",
        "syd,syd-sam,watchdog-hairpindeployer,hypersam": "sam-0001568-53c1b42b",
        "yhu,yhu-sam,watchdog-hairpindeployer,hypersam": "sam-0001568-53c1b42b",
        "yul,yul-sam,watchdog-hairpindeployer,hypersam": "sam-0001568-53c1b42b",

        # [rbhat] Fix synthetic watchdog in GIA
        "chx,chx-sam,watchdog-synthetic,hypersam": "sam-0001619-308fa232",
        "wax,wax-sam,watchdog-synthetic,hypersam": "sam-0001619-308fa232",

        #[mayank.kumar] testing email reporting for deployment and statefulsets
        "prd,prd-sam,k8s-resource-reporter,hypersam": "sam-0001662-26aee930",

         #[rbhat] cache namespace, node list in controller
        "prd,prd-sam,samcontrol,hypersam": "sam-0001654-3f9cfd66",

        #[prahlad.joshi] scrapper sends kind for watch events
        "dfw,dfw-sam,snapshoter,hypersam": "sam-0001669-de304b55",
        "phx,phx-sam,snapshoter,hypersam": "sam-0001669-de304b55",
        "frf,frf-sam,snapshoter,hypersam": "sam-0001669-de304b55",
        "prd,prd-samdev,snapshoter,hypersam": "sam-0001669-de304b55",
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
            hypersam: "sam-0001667-72dcabb0",
            madkub: "1.0.0-0000061-74e4a7b6",
            madkubSidecar: "1.0.0-0000061-74e4a7b6",
            },

        ### Release Phase 2 - PRD Sandbox and prd-sdc
        "2": {
            hypersam: "sam-0001641-fafe532f",
            madkub: "1.0.0-0000058-3855b6fd",
            madkubSidecar: "1.0.0-0000058-3855b6fd",
            },

        ### Release Phase 3 - Canary Prod FRF
        "3": {
            hypersam: "sam-0001641-fafe532f",
            madkub: "1.0.0-0000058-3855b6fd",
            madkubSidecar: "1.0.0-0000058-3855b6fd",
            },

        ### Release Phase 4 - Rest of Prod
        "4": {
            hypersam: "sam-0001641-fafe532f",
            madkub: "1.0.0-0000058-3855b6fd",
            madkubSidecar: "1.0.0-0000058-3855b6fd",
            },

        ### Temporary phase just for public cloud
        # We are keeping this on an old build until we upgrade to k8s 1.7
        # (which is blocked on the hairpin fix)
        # After that, we will eliminate this phase and re-add these kingdoms
        # phases 1-4
        pub: {
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
        else if (kingdom == "frf") then
            "3"
        else if utils.is_public_cloud(kingdom) then
            "pub"
        else
            "4"
        ),

    # Static images that do not go in phases
    static: {
        k8sproxy: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/cbatra/haproxy:20170614_183811.a8a02a5.clean.cbatra-ltm1",
        prometheus: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/cbatra/prometheus:20180124",
        permissionInitContainer: (
            if (kingdom == "prd") then
                "sam-c07d4afb-673"
            else
                "sam-1ebeb0ac-657"
        ),

        k4aInitContainerImage: (
            if (kingdom == "prd" || kingdom == "frf") then
                "sam-0001548-81d3b9bd"
        ),
    },

    # ====== DO NOT EDIT BELOW HERE ======

    # These are the images used by the templates
    hypersam: utils.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].hypersam),
    k8sproxy: utils.do_override_based_on_tag($.overrides, "sam", "k8sproxy", $.static.k8sproxy),
    prometheus: utils.do_override_based_on_tag($.overrides, "sam", "prometheus", $.static.prometheus),
    permissionInitContainer: utils.do_override_based_on_tag($.overrides, "sam", "hypersam", $.static.permissionInitContainer),
    k4aInitContainerImage: utils.do_override_based_on_tag($.overrides, "sam", "hypersam", $.static.k4aInitContainerImage),

    # madkub is for the server, the sidecar is for the injected containers. They are different because hte injected force a restart
    # of all containers
    madkub: utils.do_override_based_on_tag($.overrides, "sam", "madkub", $.per_phase[$.phase].madkub),

    # override need to follow the phase as we are changing the format.
    madkubSidecar: if $.per_phase[$.phase].hypersam == "sam-0001355-581a778b" then
                "sam/madkub:" + $.per_phase[$.phase].madkubSidecar
            else
                utils.do_override_based_on_tag($.overrides, "sam", "madkub", $.per_phase[$.phase].madkubSidecar),

}
