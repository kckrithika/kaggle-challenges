local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local utils = import "util_functions.jsonnet";
local configs = import "config.jsonnet";
local samreleases = import "samreleases.json";

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
        #   "prd,prd-sam,samcontrol,hypersam": "2690-3c76e4d1bc7bebf17bfa304fd309dc9332acd196",

        # Added this override to fix the peimission issue of connectivitylabeler watchdog
        "prd,prd-samtest,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "prd,prd-samdev,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "prd,prd-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "cdg,cdg-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "cdu,cdu-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "chx,chx-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "dfw,dfw-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "fra,fra-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "frf,frf-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "hio,hio-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "hnd,hnd-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "ia2,ia2-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "iad,iad-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "lo2,lo2-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "lo3,lo3-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "ord,ord-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "par,par-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "ph2,ph2-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "phx,phx-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "syd,syd-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "ttd,ttd-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "ukb,ukb-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "wax,wax-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "yhu,yhu-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",
        "yul,yul-sam,sam-network-reporter,hypersam": "2754-365539f3b19f1f92f8ee7f1778f157769fae2a07",

        },

    ### Per-phase image tags have been moved to samreleases.json

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-samtest" || kingdom == "mvp") then
            "1"
        else if (estate == "prd-samdev") then
            "2"
        else if (estate != "prd-samtwo") && (kingdom == "prd" || kingdom == "xrd") then
            "3"
        else if (kingdom == "frf") || (kingdom == "cdu") then
            "4"
        else
            "5"
        ),

    phaseNum: std.parseInt($.phase),
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

        k4aInitContainerImage: (
            "2778-29ee2fa3a4532165211b8adae39ecf04c451a410"
        ),
        local kubedns_image_tag = "1.14.9",
        local strata_registry = configs.registry + "/dva",
        kubedns: strata_registry + "/k8s-dns-kube-dns:" + kubedns_image_tag,
        kubednsmasq: strata_registry + "/k8s-dns-dnsmasq-nanny:" + kubedns_image_tag,
        kubednssidecar: strata_registry + "/k8s-dns-sidecar:" + kubedns_image_tag,
        madkubPCN: "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-gcp/dva/sam/madkub:108-f011ff42f384e0d22ea5b916ee2f3c2146850b2f",
    },

    # ====== DO NOT EDIT BELOW HERE ======

    # These are the images used by the templates
    hypersam: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", samreleases[$.phase].hypersam.label),
    k8sproxy: imageFunc.do_override_based_on_tag($.overrides, "sam", "k8sproxy", $.static.k8sproxy),
    prometheus: imageFunc.do_override_based_on_tag($.overrides, "sam", "prometheus", $.static.prometheus),
    permissionInitContainer: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.static.permissionInitContainer),
    k4aInitContainerImage: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.static.k4aInitContainerImage),
    kubedns: imageFunc.do_override_based_on_tag($.overrides, "sam", "kubedns", $.static.kubedns),
    kubednsmasq: imageFunc.do_override_based_on_tag($.overrides, "sam", "kubednsmasq", $.static.kubednsmasq),
    kubednssidecar: imageFunc.do_override_based_on_tag($.overrides, "sam", "kubednssidecar", $.static.kubednssidecar),

    # madkub is for the server, the sidecar is for the injected containers. They are different because hte injected force a restart
    # of all containers
    madkub: imageFunc.do_override_based_on_tag($.overrides, "sam", "madkub", samreleases[$.phase].madkub.label),
    madkubSidecar: imageFunc.do_override_based_on_tag($.overrides, "sam", "madkub", samreleases[$.phase].madkubSidecar.label),

    # image_functions needs to know the filename of the template we are processing
    # Each template must set this at time of importing this file, for example:
    #
    # "local someteamimages = (import "someteamimages.jsonnet")  + { templateFilename:: std.thisFile };"
    #
    # Then we pass this again into image_functions at time of import.
    templateFilename:: error "templateFilename must be passed at time of import",
    local imageFunc = (import "image_functions.libsonnet") + { templateFilename:: $.templateFilename },
}
