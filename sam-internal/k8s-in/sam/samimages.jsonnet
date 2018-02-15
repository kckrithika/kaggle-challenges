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

        # [diana.chang] Testing daily deployer and setting the 'auto' keyword for particular resources, changed watchdog-sdp in prd-samtest so it doesn't use a keyword
        "prd,prd-samtest,samcontrol-deployer,hypersam": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/diana.chang/hypersam:20180131_154915.d7abb274.dirty.dianachang-ltm1",
        "prd,prd-samdev,samcontrol-deployer,hypersam": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/diana.chang/hypersam:20180131_154915.d7abb274.dirty.dianachang-ltm1",
        "prd,prd-samtest,watchdog-sdp,hypersam": "auto",

        # [jiayi] Deploying snapshotconsumer to prd-samdev & prd-sam
        "prd,prd-samdev,snapshotconsumer,hypersam": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/jiayi.yan/consumer:v3",
        "prd,prd-sam,snapshotconsumer,hypersam": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/jiayi.yan/consumer:v3",

        #[Xiao] Deploying samapp controller to prd-samtest for hackweek
        "prd,prd-samtest,samapp-controller,hypersam": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/xiao.zhou/hypersam:20180207_130606.13d405d5.dirty.xiaozhou-ltm2",

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

        # [d.smith] Early push of new hypersam - fixes snapshotter
        "prd,prd-samdev,snapshoter,hypersam": "auto",
        "frf,frf-sam,snapshoter,hypersam": "sam-0001710-3ec484d6",
        "dfw,dfw-sam,snapshoter,hypersam": "sam-0001710-3ec484d6",
        "phx,phx-sam,snapshoter,hypersam": "sam-0001710-3ec484d6",
        "cdu,cdu-sam,snapshoter,hypersam": "sam-0001710-3ec484d6",
        "chx,chx-sam,snapshoter,hypersam": "sam-0001710-3ec484d6",
        "hnd,hnd-sam,snapshoter,hypersam": "sam-0001710-3ec484d6",
        "iad,iad-sam,snapshoter,hypersam": "sam-0001710-3ec484d6",
        "ord,ord-sam,snapshoter,hypersam": "sam-0001710-3ec484d6",
        "par,par-sam,snapshoter,hypersam": "sam-0001710-3ec484d6",
        "syd,syd-sam,snapshoter,hypersam": "sam-0001710-3ec484d6",
        "ukb,ukb-sam,snapshoter,hypersam": "sam-0001710-3ec484d6",
        "wax,wax-sam,snapshoter,hypersam": "sam-0001710-3ec484d6",
        "yhu,yhu-sam,snapshoter,hypersam": "sam-0001710-3ec484d6",
        "yul,yul-sam,snapshoter,hypersam": "sam-0001710-3ec484d6",

        # [cdebains] Override phase-deployment for controller to enable colocation.
        "prd,prd-samtest,samcontrol,hypersam": "sam-0001716-d493443b",
        "prd,prd-samdev,samcontrol,hypersam": "sam-0001716-d493443b",

        # [mayank] Deploy Stateful Revision cleanup Until we upgrade to 1.9
        "prd,prd-samdev,stateful-revision-cleaner,hypersam": "sam-0001715-154deff7",
        "prd,prd-sam,stateful-revision-cleaner,hypersam": "sam-0001715-154deff7",

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
            hypersam: "sam-0001710-3ec484d6",
            madkub: "1.0.0-0000061-74e4a7b6",
            madkubSidecar: "1.0.0-0000061-74e4a7b6",
            },

        ### Release Phase 2 - PRD Sandbox and prd-sdc
        "2": {
            hypersam: "sam-0001710-3ec484d6",
            madkub: "1.0.0-0000061-74e4a7b6",
            madkubSidecar: "1.0.0-0000061-74e4a7b6",
            },

        ### Release Phase 3 - Canary Prod FRF
        "3": {
            hypersam: "sam-0001667-72dcabb0",
            madkub: "1.0.0-0000061-74e4a7b6",
            madkubSidecar: "1.0.0-0000061-74e4a7b6",
            },

        ### Release Phase 4 - Rest of Prod
        "4": {
            hypersam: "sam-0001667-72dcabb0",
            madkub: "1.0.0-0000061-74e4a7b6",
            madkubSidecar: "1.0.0-0000061-74e4a7b6",
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
            if (estate == "prd-samdev" || estate == "prd-samtest") then
               "sam-0001721-43ca853b"
            else if (kingdom == "prd" || kingdom == "frf") then
                "sam-0001548-81d3b9bd"
        ),
    },

    # ====== DO NOT EDIT BELOW HERE ======

    # These are the images used by the templates
    hypersam: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].hypersam),
    k8sproxy: imageFunc.do_override_based_on_tag($.overrides, "sam", "k8sproxy", $.static.k8sproxy),
    prometheus: imageFunc.do_override_based_on_tag($.overrides, "sam", "prometheus", $.static.prometheus),
    permissionInitContainer: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.static.permissionInitContainer),
    k4aInitContainerImage: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.static.k4aInitContainerImage),

    # madkub is for the server, the sidecar is for the injected containers. They are different because hte injected force a restart
    # of all containers
    madkub: imageFunc.do_override_based_on_tag($.overrides, "sam", "madkub", $.per_phase[$.phase].madkub),

    # override need to follow the phase as we are changing the format.
    madkubSidecar: if $.per_phase[$.phase].hypersam == "sam-0001355-581a778b" then
                "sam/madkub:" + $.per_phase[$.phase].madkubSidecar
            else
                imageFunc.do_override_based_on_tag($.overrides, "sam", "madkub", $.per_phase[$.phase].madkubSidecar),

    # image_functions needs to know the filename of the template we are processing
    # Each template must set this at time of importing this file, for example:
    #
    # "local someteamimages = (import "someteamimages.jsonnet")  + { templateFilename:: std.thisFile };"
    #
    # Then we pass this again into image_functions at time of import.
    templateFilename:: error "templateFilename must be passed at time of import",
    local imageFunc = (import "image_functions.libsonnet") + { templateFilename:: $.templateFilename },
}
