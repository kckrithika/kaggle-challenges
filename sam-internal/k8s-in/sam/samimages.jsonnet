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

        # [prahlad.joshi] Releasing kubeletchecker changes to prd-samtest
        "prd,prd-samdev,watchdog-common,hypersam": "sam-0001900-a46c47b5",
        "prd,prd-samtest,watchdog-common,hypersam": "sam-0001900-a46c47b5",
        "prd,prd-sam,watchdog-common,hypersam": "sam-0001900-a46c47b5",

        #[xiao.zhou] Test sam-api-proxy and samapp controller
        "prd,prd-sam,sam-api-proxy,hypersam": "sam-0001856-d20c959b",
        "prd,prd-sam,samapp-controller,hypersam": "sam-0001853-500861a8",

        #[jiayi.yan] Roll out sam app status CRD of samcontrol where SDP runs
        "prd,prd-sam,samcontrol,hypersam": "sam-0001848-170a0744",
        "prd,prd-samtwo,samcontrol,hypersam": "sam-0001848-170a0744",
        "prd,prd-sdc,samcontrol,hypersam": "sam-0001848-170a0744",

        #[d.smith] Rollout change to daemonset rollouts to prevent SLB outages while
        #api servers are under heavy load
        "prd,prd-sam,samcontrol-deployer,hypersam": "sam-0001854-6406a7e5",

        #[rbhat] Delete orphan deployments,services on resync
        "prd,prd-samdev,bundle-controller,hypersam": "sam-0001886-9f1535db",
        "prd,prd-sam,bundle-controller,hypersam": "sam-0001886-9f1535db",

        #[rbhat] skip e2e namespace in proxy validator
        "prd,prd-samdev,sam-api-proxy,hypersam": "sam-0001886-9f1535db",

        #[a.mitra] deploy latest sql watchdog in prd
        "prd,prd-sam,watchdog-samsql,hypersam": "sam-0001894-7c4f0d45",

        #[lizhang.li] rollout filesystem watchdog with hidden file checker in prd
        "prd,prd-sam,watchdog-filesystem,hypersam": "sam-0001898-b97eccee",
        "prd,prd-samdev,watchdog-filesystem,hypersam": "sam-0001898-b97eccee",
        "prd,prd-samtest,watchdog-filesystem,hypersam": "sam-0001898-b97eccee",
        },

    ### Per-phase image tags
    per_phase: {

        ### Release Phase 0 - Nightly deployment of the most recent hypersam to prd-samtest
        # Under normal cirumstances we should not need to change this section.
        # Overrides work just fine in this phase.  To see the active hypersam tag visit:
        # https://git.soma.salesforce.com/sam/sam/wiki/SAM-Auto-Deployer#how-to-find-phase-0-hypersam-tag

        "0": {
             hypersam: "auto",
             madkub: $.per_phase["1"].madkub,
             madkubSidecar: $.per_phase["1"].madkubSidecar,
             },

        ### Release Phase 1 - prd-samdev
        # See https://git.soma.salesforce.com/sam/sam/wiki/Deploy-SAM on how to pick the correct tag
        # As much as possible, we want to use a tag that is running well in phase 0 above.
        # When rolling this phase, remove all overrides from test beds above
        # Make sure there are no critical watchdogs firing before/after the release, and check SAMCD emails to make sure all rolled properly

        "1": {
            hypersam: "sam-0001880-098eaa65",
            madkub: "1.0.0-0000066-fedd8bce",
            madkubSidecar: "1.0.0-0000061-74e4a7b6",
            },

        ### Release Phase 2 - PRD Sandbox and prd-sdc
        "2": {
            hypersam: "sam-0001847-1b9453cd",
            madkub: "1.0.0-0000066-fedd8bce",
            madkubSidecar: "1.0.0-0000061-74e4a7b6",
            },

        ### Release Phase 3 - Canary Prod FRF / Pub CDU
        "3": {
            hypersam: "sam-0001847-1b9453cd",
            madkub: "1.0.0-0000066-fedd8bce",
            madkubSidecar: "1.0.0-0000061-74e4a7b6",
            },

        ### Release Phase 4 - Rest of Prod + Pub + Gia (Pub overridden by 'pub' phase for now)
        "4": {
            hypersam: "sam-0001847-1b9453cd",
            madkub: "1.0.0-0000066-fedd8bce",
            madkubSidecar: "1.0.0-0000061-74e4a7b6",
            },

           madkub: $.per_phase["1"].madkub,
           madkubSidecar: $.per_phase["1"].madkubSidecar,
        },

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-samtest") then
            "0"
        else if (estate == "prd-samdev") then
            "1"
        else if (kingdom == "prd") then
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
        k8sproxy: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/cbatra/haproxy:20170614_183811.a8a02a5.clean.cbatra-ltm1",
        prometheus: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/cbatra/prometheus:20180124",
        permissionInitContainer: (
            if (kingdom == "prd") then
                "sam-c07d4afb-673"
            else
                "sam-1ebeb0ac-657"
        ),

        k4aInitContainerImage: "sam-0001800-1972769a",
        kubedns: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/mayank.kumar/k8s-dns-kube-dns-amd64:1.14.1",
        kubednsmasq: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/mayank.kumar/k8s-dns-dnsmasq-nanny-amd64:1.14.1",
        kubednssidecar: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/mayank.kumar/k8s-dns-sidecar-amd64:1.14.1",
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
