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
        #   # [alias] Added this override to fix issue xxx
        #   "prd,prd-sam,samcontrol,hypersam": "sam-0000123-deadbeef",

        # [cbatra] Deploying node controller changes for PRD IP issue
        "prd,prd-samdev,node-controller,hypersam": "sam-0002192-400bcafb",
        "prd,prd-samdev,samcontrol,hypersam": "sam-0002192-400bcafb",

         # [cbatra] Deploying node controller changes for PRD IP issue
        "prd,prd-sam,node-controller,hypersam": "sam-0002192-400bcafb",
        "prd,prd-sam,samcontrol,hypersam": "sam-0002192-400bcafb",

        # [thargrove] Enable multi-query pages in sam-sql-reporter
        "prd,prd-sam,sam-sql-reporter,hypersam": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/thargrove/hypersam:20180807_165826.3d22ff09.dirty.thargrove-ltm1",

        # [small] slice 2: update watchdog img
        "prd,prd-samtest,watchdog-comparek8sresources,hypersam": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/small/hypersam:20180810_102303.fc5ddde7.dirty.small-ltm",

        },

    ### Per-phase image tags
    per_phase: {

        ### Release Phase 0 - Nightly deployment of the most recent hypersam to prd-samtest
        # Under normal cirumstances we should not need to change this section.
        # Overrides work just fine in this phase.  To see the active hypersam tag visit:
        # https://git.soma.salesforce.com/sam/sam/wiki/SAM-Auto-Deployer#how-to-find-phase-0-hypersam-tag

        # NOTE:
        # Each phase is overlayed on the next phase.  This means that for things that are the same everywhere
        # you are free to simply define it only in Phase4 and all the rest will inherit it.

        ### Release Phase 0 - prd-samtest
        "0": $.per_phase["1"] {
             hypersam: "auto",
             },

        ### Release Phase 1 - prd-samdev
        # See https://git.soma.salesforce.com/sam/sam/wiki/Deploy-SAM on how to pick the correct tag
        # As much as possible, we want to use a tag that is running well in phase 0 above.
        # When rolling this phase, remove all overrides from test beds above
        # Make sure there are no critical watchdogs firing before/after the release, and check SAMCD emails to make sure all rolled properly

        ### Release Phase 1 - prd-samdev
        "1": $.per_phase["2"] {
            hypersam: "sam-0002190-d048106f",
            madkub: "1.0.0-0000074-4c95976a",
            madkubSidecar: "1.0.0-0000074-4c95976a",
            },

        ### Release Phase 2 - PRD Sandbox and prd-sdc
        "2": $.per_phase["3"] {
            hypersam: "sam-0002190-d048106f",
            madkub: "1.0.0-0000074-4c95976a",
            madkubSidecar: "1.0.0-0000074-4c95976a",
            },

        ### Release Phase 3 - Canary Prod FRF / Pub CDU
        "3": $.per_phase["4"] {
            hypersam: "sam-0002190-d048106f",
            madkub: "1.0.0-0000074-4c95976a",
            madkubSidecar: "1.0.0-0000074-4c95976a",
            },

        ### Release Phase 4 - Rest of Prod + Pub + Gia
        "4": {
            hypersam: "sam-0002160-cdd63ff0",
            madkub: "1.0.0-0000071-5a6dcab2",
            madkubSidecar: "1.0.0-0000071-5a6dcab2",
            },

        },

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-samtest") then
            "0"
        else if (estate == "prd-samdev") then
            "1"
        else if (estate != "prd-samtwo") && (kingdom == "prd") then
            "2"
        else if (kingdom == "frf") || (kingdom == "cdu") then
            "3"
        else
            "4"
        ),

    # Static images that do not go in phases
    # [Important Note]: When you are changing images in for initContainers/sidecars  they are not promoted to prod by default. This need to be
    # fixed in the image promotion logic in SMB. For now the workaround is to update the image of a watchdog in one prod DC so that the image is promoted
    # Please be very careful when making such a change
    static: {
        k8sproxy: "ops0-artifactrepo1-0-" + kingdom + ".data.sfdc.net/docker-sam/cbatra/haproxy:20170614_183811.a8a02a5.clean.cbatra-ltm1",
        prometheus: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/cbatra/prometheus:20180124",
        permissionInitContainer: (
            if (kingdom == "prd") then
                "sam-c07d4afb-673"
            else
                "sam-1ebeb0ac-657"
        ),

        k4aInitContainerImage: "sam-0001948-03d9baca",
        kubedns: (
            if (estate == "prd-samdev" || estate == "prd-samtest") then
                "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/mayank.kumar/k8s-dns-kube-dns-amd64:1.14.10-2-g71f9bf5-dirty"
            else
                "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/mayank.kumar/k8s-dns-kube-dns-amd64:1.14.1"
           ),

        kubednsmasq: (
            if (estate == "prd-samdev" || estate == "prd-samtest") then
                "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/mayank.kumar/k8s-dns-dnsmasq-nanny-amd64:1.14.10-2-g71f9bf5-dirty"
            else
                "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/mayank.kumar/k8s-dns-dnsmasq-nanny-amd64:1.14.1"
           ),
        kubednssidecar: (
            if (estate == "prd-samdev" || estate == "prd-samtest") then
                "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/mayank.kumar/k8s-dns-sidecar-amd64:1.14.10-2-g71f9bf5-dirty"
            else
                "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/mayank.kumar/k8s-dns-sidecar-amd64:1.14.1"
           ),

    },

    # ====== DO NOT EDIT BELOW HERE ======

    # These are the images used by the templates
    hypersam: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].hypersam),
    k8sproxy: imageFunc.do_override_based_on_tag($.overrides, "sam", "k8sproxy", $.static.k8sproxy),
    prometheus: imageFunc.do_override_based_on_tag($.overrides, "sam", "prometheus", $.static.prometheus),
    permissionInitContainer: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.static.permissionInitContainer),
    k4aInitContainerImage: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.static.k4aInitContainerImage),
    kubedns: imageFunc.do_override_based_on_tag($.overrides, "sam", "kubedns", $.static.kubedns),
    kubednsmasq: imageFunc.do_override_based_on_tag($.overrides, "sam", "kubednsmasq", $.static.kubednsmasq),
    kubednssidecar: imageFunc.do_override_based_on_tag($.overrides, "sam", "kubednssidecar", $.static.kubednssidecar),

    # madkub is for the server, the sidecar is for the injected containers. They are different because hte injected force a restart
    # of all containers
    madkub: imageFunc.do_override_based_on_tag($.overrides, "sam", "madkub", $.per_phase[$.phase].madkub),
    madkubSidecar: imageFunc.do_override_based_on_tag($.overrides, "sam", "madkub", $.per_phase[$.phase].madkubSidecar),

    # image_functions needs to know the filename of the template we are processing
    # Each template must set this at time of importing this file, for example:
    #
    # "local someteamimages = (import "someteamimages.jsonnet")  + { templateFilename:: std.thisFile };"
    #
    # Then we pass this again into image_functions at time of import.
    templateFilename:: error "templateFilename must be passed at time of import",
    local imageFunc = (import "image_functions.libsonnet") + { templateFilename:: $.templateFilename },
}
