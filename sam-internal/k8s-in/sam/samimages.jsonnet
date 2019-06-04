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

        #[a.mitra] turn on synthetic checker without PV in sam-test
        "prd,prd-samtest,watchdog-synthetic,hypersam": "2727-8ff8b127b0a2856c5f9392ce332653062249aaf2",

        #[thargrove] Needed only until Artifactory adds a docker-all alias to docker-gcp in XRD 2-0
        "mvp,gsf-core-devmvp-sam2-sam,*,hypersam": "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-gcp/dva/sam/hypersam:2601-1bbc5de4786678763a4e8a71681ee42ada887c76",
        "mvp,gsf-core-devmvp-sam2-samtest,*,hypersam": "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-gcp/dva/sam/hypersam:2601-1bbc5de4786678763a4e8a71681ee42ada887c76",

        #[cdebains] Override with strata that's ready
        "mvp,gsf-core-devmvp-sam2-sam,*,madkub": "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-gcp/dva/sam/madkub:105-93f66ec3114a4a5f805ac2bc889903f7fc63c32e",
        "mvp,gsf-core-devmvp-sam2-samtest,*,madkub": "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-gcp/dva/sam/madkub:105-93f66ec3114a4a5f805ac2bc889903f7fc63c32e",

        #[hsuanyu-chen] Enable Internal Load Balancer in PCN
        "mvp,gsf-core-devmvp-sam2-sam,samapp-controller,hypersam": "2686-546f034ba27d1c5facfa2a87cb56b59d5f4faacf",
        "mvp,gsf-core-devmvp-sam2-samtest,samapp-controller,hypersam": "2686-546f034ba27d1c5facfa2a87cb56b59d5f4faacf",

        #[prabh-singh] Fix AutoDeployer error/override in GIA
        "ttd,ttd-sam,samcontrol-deployer,hypersam": "sam-0002532-de840aef",
        "hio,hio-sam,samcontrol-deployer,hypersam": "sam-0002532-de840aef",


        #[xiao.zhou] Override Synthetic watchdog so the alert won't go off
        "frf,frf-sam,watchdog-synthetic,hypersam": "2688-26c72ce1be33f92fc7bc5441c0a5ff668c961d78",

        #[d.smith] Override kuberesource checker
        "prd,prd-sam,watchdog-kuberesource,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "prd,prd-samdev,watchdog-kuberesource,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "prd,prd-samtest,watchdog-kuberesource,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "prd,prd-samtwo,watchdog-kuberesource,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "prd,prd-sdc,watchdog-kuberesource,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "cdg,cdg-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "cdu,cdu-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "chx,chx-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "dfw,dfw-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "fra,fra-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "frf,frf-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "hio,hio-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "hnd,hnd-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "ia2,ia2-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "iad,iad-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "io2,io2-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "io3,io3-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "mvp,mvp-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "ord,ord-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "par,par-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "ph2,ph2-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "phx,phx-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "prd,prd-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "syd,syd-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "ttd,ttd-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "ukb,ukb-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "wax,wax-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "xrd,xrd-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "yhu,yhu-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",
        "yul,yul-sam,watchdog-kuberesources,hypersam": "2712-49c6098a85641d114c3f44b4ed9f3a1be26bb7b5",

        # [toli] Override etcdchecker to introduce more logging
        "prd,prd-sam,watchdog-etcd,hypersam": "2737-afb27b9bdf88a8da458bc8a476467f6e125269aa",

        #[xiao.zhou] Override crd watcher for team "secrets"
        "xrd,xrd-sam,crd-watcher,hypersam": "2690-3c76e4d1bc7bebf17bfa304fd309dc9332acd196",

        #[xiao.zhou] Override samapp controller for a bug showed in elastic search in prd-sam
        "prd,prd-sam,samapp-controller,hypersam": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/xiao.zhou/hypersam:20190415_152129.1843c9f94.clean.xiaozhou-ltm2",
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

        k4aInitContainerImage: "sam-0002447-69fdc914",
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
