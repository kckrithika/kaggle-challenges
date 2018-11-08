local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local utils = import "util_functions.jsonnet";
local configs = import "config.jsonnet";

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

        #[xiao] Fix synthetic in prd
        "prd,prd-samtest,temp-crd-watcher,hypersam": "sam-0002369-86f6c658",
        "prd,prd-samdev,temp-crd-watcher,hypersam": "sam-0002369-86f6c658",
        "prd,prd-sam,temp-crd-watcher,hypersam": "sam-0002369-86f6c6582",
        "prd,prd-samdev,samapp-controller,hypersam": "sam-0002365-809ebf54",

         #[min.wang] Test Watchdog InitMetricsClient
         "prd, prd-samtest, node-controller, hypersam": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/min.wang/hypersam:20181029_160337.c61213b4.clean.minwang-ltm0",

        }
        + {
           #[prabh.singh] Pin the watchdogs to use new hypersam that honors email frequency.Remove in next phase release
           [std.substr(ce, 0, 3) + "," + ce + "," + wd + ",hypersam"]: "sam-0002347-34f588d0"
for ce in [
                        "cdg-sam",
                        "cdu-sam",
                        "chx-sam",
                        "dfw-sam",
                        "fra-sam",
                        "hnd-sam",
                        "ia2-sam",
                        "iad-sam",
                        "ord-sam",
                        "par-sam",
                        "ph2-sam",
                        "phx-sam",
                        "prd-samtwo",
                        "prd-sdc",
                        "syd-sam",
                        "ukb-sam",
                        "wax-sam",
                        "xrd-sam",
                        "yhu-sam",
                        "yul-sam",
]
           for wd in [
                        "watchdog-apiserverlb",
                        "watchdog-common",
                        "watchdog-comparek8sresources",
                        "watchdog-deployment",
                        "watchdog-dns",
                        "watchdog-estatesvc",
                        "watchdog-etcd-quorum",
                        "watchdog-etcd",
                        "watchdog-filesystem",
                        "watchdog-hairpindeployer",
                        "watchdog-k8sproxy",
                        "watchdog-kuberesources",
                        "watchdog-maddog",
                        "watchdog-maddogcert",
                        "watchdog-manifestzip",
                        "watchdog-master",
                        "watchdog-node-controller",
                        "watchdog-node",
                        "watchdog-pullrequest",
                        "watchdog-puppet",
                        "watchdog-rbac",
                        "watchdog-samsql",
                        "watchdog-sdp",
                        "watchdog-synthetic",
                ]
        }
        #[karim] Network reporter with port and high api server query fixes
        + {
            [std.substr(cl, 0, 3) + "," + cl + "," + "sam-network-reporter" + ",hypersam"]: "sam-0002364-0a657f10"
            for cl in [
                "frf-sam",
                "prd-sam",
                "prd-samdev",
                "prd-sam_storage",
                "prd-sam_storagedev",
                "prd-samtest",
                "prd-samtwo",
                "prd-sdc",
                "xrd-sam",
            ]
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
        "1": $.per_phase["2"] {
            # IMPORTANT! Follow all steps from https://git.soma.salesforce.com/sam/sam/wiki/Deploy-SAM
            hypersam: "sam-0002362-f00e1afb",
            },

        ### Release Phase 2 - prd-sam, xrd-sam, and everything else in prd except prd-samtwo
        "2": $.per_phase["3"] {
            hypersam: "sam-0002362-f00e1afb",
            },

        ### Release Phase 3 - Canary Prod FRF / Pub CDU
        "3": $.per_phase["4"] {
            hypersam: "sam-0002336-6a8184c1",
            },

        ### Release Phase 4 - Rest of Prod + Pub + Gia + prd-samtwo
        "4": {
            hypersam: "sam-0002336-6a8184c1",
            madkub: "1.0.0-0000077-b1d3a629",
            madkubSidecar: "1.0.0-0000077-b1d3a629",
            },

        },

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-samtest") then
            "0"
        else if (estate == "prd-samdev") then
            "1"
        else if (estate != "prd-samtwo") && (kingdom == "prd" || kingdom == "xrd") then
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
        local kubedns_image_tag = "1.14.9",
        local strata_registry = configs.registry + "/dva",
        kubedns: strata_registry + "/k8s-dns-kube-dns:" + kubedns_image_tag,
        kubednsmasq: strata_registry + "/k8s-dns-dnsmasq-nanny:" + kubedns_image_tag,
        kubednssidecar: strata_registry + "/k8s-dns-sidecar:" + kubedns_image_tag,
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
