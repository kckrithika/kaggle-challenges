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
        #   "prd,prd-sam,samcontrol,hypersam": "sam-0000123-deadbeef",

        #[pjoshi] Fixing manifest-repo-watcher
        "prd,prd-sam,sam-manifest-repo-watcher,hypersam": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/prahlad.joshi/hypersam:20190206_191653.c5206861.dirty.prahladjos-ltm",

        #[xiao]
        "prd,prd-sam,samapp-controller,hypersam": "sam-0002472-fe691728",
        "frf,frf-sam,samapp-controller,hypersam": "sam-0002472-fe691728",

        #[small] sythetic checker failure fix
        "prd,prd-samtest,watchdog-synthetic,hypersam": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/small/hypersam:20190118_133746.5f7caad8.dirty.small-ltm",

        #[thargrove] Needed only until Artifactory adds a docker-all alias to docker-gcp in XRD 2-0
        "mvp,gsf-core-devmvp-sam2-sam,*,hypersam": "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-gcp/dva/sam/hypersam:2601-1bbc5de4786678763a4e8a71681ee42ada887c76",
        "mvp,gsf-core-devmvp-sam2-samtest,*,hypersam": "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-gcp/dva/sam/hypersam:2601-1bbc5de4786678763a4e8a71681ee42ada887c76",

        #[thargrove] Switch to strata build when its ready
        "mvp,gsf-core-devmvp-sam2-sam,*,madkub": "gcr.io/gsf-core-devmvp-sam2/thargrove/madkubserver:1.0.0-0000080-8a8659dd",
        "mvp,gsf-core-devmvp-sam2-samtest,*,madkub": "gcr.io/gsf-core-devmvp-sam2/thargrove/madkubserver:1.0.0-0000080-8a8659dd",

        #[hsuanyu-chen] Enable Internal Load Balancer in PCN
        "mvp,gsf-core-devmvp-sam2-sam,samapp-controller,hypersam": "2624-bee71f3d174816e59a880f0e94d79e3479846842",
        "mvp,gsf-core-devmvp-sam2-samtest,samapp-controller,hypersam": "2624-bee71f3d174816e59a880f0e94d79e3479846842",

         #[raksha] crdwatcher fix for synthetic
         "prd,prd-samtest,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "prd,prd-samdev,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "prd,prd-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "frf,frf-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "cdg,cdg-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "cdu,cdu-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "dfw,dfw-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "fra,fra-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "hnd,hnd-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "iad,iad-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "ia2,ia2-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "lo3,lo3-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "lo2,lo2-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "ord,ord-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "par,par-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "ph2,ph2-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "phx,phx-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "syd,syd-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "ukb,ukb-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "wax,wax-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "xrd,xrs-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "yhu,yhu-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",
         "yul,yul-sam,crd-watcher,hypersam": "sam-0002494-cefb0d82",


         #[raksha] Bundlecontroller fix
         "prd,prd-samtest,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "prd,prd-samdev,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "prd,prd-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "frf,frf-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "cdg,cdg-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "cdu,cdu-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "dfw,dfw-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "fra,fra-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "hnd,hnd-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "iad,iad-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "ia2,ia2-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "lo3,lo3-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "lo2,lo2-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "ord,ord-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "par,par-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "ph2,ph2-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "phx,phx-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "syd,syd-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "ukb,ukb-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "wax,wax-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "xrd,xrs-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "yhu,yhu-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",
         "yul,yul-sam,bundle-controller,hypersam": "sam-0002499-db36ef44",


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

        k4aInitContainerImage: "sam-0002447-69fdc914",
        local kubedns_image_tag = "1.14.9",
        local strata_registry = configs.registry + "/dva",
        kubedns: strata_registry + "/k8s-dns-kube-dns:" + kubedns_image_tag,
        kubednsmasq: strata_registry + "/k8s-dns-dnsmasq-nanny:" + kubedns_image_tag,
        kubednssidecar: strata_registry + "/k8s-dns-sidecar:" + kubedns_image_tag,
        madkubPCN: "gcr.io/gsf-core-devmvp-sam2/thargrove/madkubserver:1.0.0-0000080-8a8659dd",
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
