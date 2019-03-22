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

        #[thargrove] Needed only until Artifactory adds a docker-all alias to docker-gcp in XRD 2-0
        "mvp,gsf-core-devmvp-sam2-sam,*,hypersam": "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-gcp/dva/sam/hypersam:2601-1bbc5de4786678763a4e8a71681ee42ada887c76",
        "mvp,gsf-core-devmvp-sam2-samtest,*,hypersam": "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-gcp/dva/sam/hypersam:2601-1bbc5de4786678763a4e8a71681ee42ada887c76",

        #[cdebains] Override with strata that's ready
        "mvp,gsf-core-devmvp-sam2-sam,*,madkub": "102-5201f60ec3458206b47cc7c1b03944e2e47aa9c7",
        "mvp,gsf-core-devmvp-sam2-samtest,*,madkub": "102-5201f60ec3458206b47cc7c1b03944e2e47aa9c7",

        #[hsuanyu-chen] Enable Internal Load Balancer in PCN
        "mvp,gsf-core-devmvp-sam2-sam,samapp-controller,hypersam": "2624-bee71f3d174816e59a880f0e94d79e3479846842",
        "mvp,gsf-core-devmvp-sam2-samtest,samapp-controller,hypersam": "2624-bee71f3d174816e59a880f0e94d79e3479846842",

        #[prabh-singh] Fix AutoDeployer error/override in GIA
        "ttd,ttd-sam,samcontrol-deployer,hypersam": "sam-0002532-de840aef",
        "hio,hio-sam,samcontrol-deployer,hypersam": "sam-0002532-de840aef",

        #[lizhang] Enable etcd healthy info persist to a local file in prd-samdev, prd-samtest and prd-sam
        "prd,prd-samdev,watchdog-etcd,hypersam": "sam-0002535-9d228ded",
        "prd,prd-samtest,watchdog-etcd,hypersam": "sam-0002535-9d228ded",
        "prd,prd-sam,watchdog-etcd,hypersam": "sam-0002535-9d228ded",

        #[thargrove] Override SDPv1 so we can point to v1.  Remove after next phase release
        "prd,prd-sam,sam-deployment-portal,hypersam": "2661-a493a755679c30705e7667661204bc9e9b8ef77e",
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
