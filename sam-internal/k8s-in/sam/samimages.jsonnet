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

        #[alok.bansal] deploy latest samp-api-proxy code to test cert rotation
        "prd,prd-sam,sam-api-proxy,hypersam": "sam-0001941-65c61fc9",

        # [prahlad.joshi] Releasing processStartTimeChecker changes to prd-sam*
        "prd,prd-sam,watchdog-common,hypersam": "sam-0001934-1a482ba7",
        "prd,prd-samdev,watchdog-common,hypersam": "sam-0001934-1a482ba7",
        "prd,prd-samtest,watchdog-common,hypersam": "sam-0001934-1a482ba7",

        # [mgrass] Releasing estate-server early in xrd to unblock ceph cluster deployment (depends on failure domain labeling done by nodecontroller).
        "xrd,xrd-sam,estate-server,hypersam": "ops0-artifactrepo1-0-xrd.data.sfdc.net/tnrp/sam/hypersam:sam-0001931-927cd1fc",

        #[jiayi.yan] Roll out sam app status CRD of samcontrol where SDP runs
        "prd,prd-samtwo,samcontrol,hypersam": "sam-0001848-170a0744",

        #[jiayi.yan] Roll out sam app status CRD in SDP
        "prd,prd-samtwo,sam-deployment-portal,hypersam": "sam-0001873-67938cc8",

        #[a.mitra] deploy liveness probe for bundlecontroller in prd-samdev
        "prd,prd-samdev,bundle-controller,hypersam": "sam-0001933-968970c4",
        "prd,prd-sam,bundle-controller,hypersam": "sam-0001933-968970c4",

        #[d.smith] Pin snapshoter to known working version
        "prd,prd-sam_storage,snapshoter,hypersam": "sam-0001847-1b9453cd",
        "cdu,cdu-sam,snapshoter,hypersam": "sam-0001898-b97eccee",
        "chx,chx-sam,snapshoter,hypersam": "sam-0001898-b97eccee",
        "dfw,dfw-sam,snapshoter,hypersam": "sam-0001898-b97eccee",
        "hnd,hnd-sam,snapshoter,hypersam": "sam-0001898-b97eccee",
        "iad,iad-sam,snapshoter,hypersam": "sam-0001898-b97eccee",
        "ord,ord-sam,snapshoter,hypersam": "sam-0001898-b97eccee",
        "par,par-sam,snapshoter,hypersam": "sam-0001898-b97eccee",
        "phx,phx-sam,snapshoter,hypersam": "sam-0001898-b97eccee",
        "syd,syd-sam,snapshoter,hypersam": "sam-0001898-b97eccee",
        "ukb,ukb-sam,snapshoter,hypersam": "sam-0001898-b97eccee",
        "wax,wax-sam,snapshoter,hypersam": "sam-0001898-b97eccee",
        "yhu,yhu-sam,snapshoter,hypersam": "sam-0001898-b97eccee",
        "yul,yul-sam,snapshoter,hypersam": "sam-0001898-b97eccee",
        "frf,frf-sam,snapshoter,hypersam": "sam-0001898-b97eccee",

        #[lizhang.li] rollout filesystem watchdog with hidden file checker in prd
        "chx,chx-sam,watchdog-filesystem,hypersam": "sam-0001898-b97eccee",
        "dfw,dfw-sam,watchdog-filesystem,hypersam": "sam-0001898-b97eccee",
        "hnd,hnd-sam,watchdog-filesystem,hypersam": "sam-0001898-b97eccee",
        "iad,iad-sam,watchdog-filesystem,hypersam": "sam-0001898-b97eccee",
        "ord,ord-sam,watchdog-filesystem,hypersam": "sam-0001898-b97eccee",
        "par,par-sam,watchdog-filesystem,hypersam": "sam-0001898-b97eccee",
        "phx,phx-sam,watchdog-filesystem,hypersam": "sam-0001898-b97eccee",
        "syd,syd-sam,watchdog-filesystem,hypersam": "sam-0001898-b97eccee",
        "ukb,ukb-sam,watchdog-filesystem,hypersam": "sam-0001898-b97eccee",
        "wax,wax-sam,watchdog-filesystem,hypersam": "sam-0001898-b97eccee",
        "yhu,yhu-sam,watchdog-filesystem,hypersam": "sam-0001898-b97eccee",
        "yul,yul-sam,watchdog-filesystem,hypersam": "sam-0001898-b97eccee",

        #[jiayi.yan] snapshotconsumer cleans 45min tombstones in mysql
        "prd,prd-sam,snapshotconsumer,hypersam": "sam-0001941-65c61fc9",

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
            hypersam: "sam-0001931-927cd1fc",
            madkub: "1.0.0-0000066-fedd8bce",
            madkubSidecar: "1.0.0-0000061-74e4a7b6",
            },

        ### Release Phase 2 - PRD Sandbox and prd-sdc
        "2": {
            hypersam: "sam-0001931-927cd1fc",
            madkub: "1.0.0-0000066-fedd8bce",
            madkubSidecar: "1.0.0-0000061-74e4a7b6",
            },

        ### Release Phase 3 - Canary Prod FRF / Pub CDU
        "3": {
            hypersam: "sam-0001912-3f0e2a18",
            madkub: "1.0.0-0000066-fedd8bce",
            madkubSidecar: "1.0.0-0000061-74e4a7b6",
            },

        ### Release Phase 4 - Rest of Prod + Pub + Gia
        "4": {
            hypersam: "sam-0001912-3f0e2a18",
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
        k8sproxy: "ops0-artifactrepo1-0-" + kingdom + ".data.sfdc.net/docker-sam/cbatra/haproxy:20170614_183811.a8a02a5.clean.cbatra-ltm1",
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
