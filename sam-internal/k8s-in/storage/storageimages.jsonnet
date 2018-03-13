local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");

{
    ### Global overrides - Anything here will override anything below.
    overrides: {
        #
        # This section lets you override any storage image for a given kingdom,estate,template,image.
        # Template is the short name of the template. For k8s-in/storage/templates/fds.jsonnet use "fds"
        # Image name
        #
        # Example:
        #   "prd,prd-sam_storage,fds,fdscontroller": "faultdomainset-0000123-deadbeef",
        #
        # Ceph daemon image override example:
        #   "prd,prd-sam_cephdev,ceph-cluster,ceph-daemon": "jewel-0000050-9308fbd0"
    },

    ### Per-phase image tags
    per_phase: {

        ### Release Phase 1 - prd-sam_storage (control plane), prd-sam_cephdev, prd-sam_sfstoredev, and prd-skipper (control plane)
        "1": {
            default_tag: "base-0000362-8c6931af",
            ceph_operator_tag: "base-0000362-8c6931af",
            sfms_tag: "latest-0000151-78ea2ca9",
            cephdaemon_tag: "jewel-0000056-50bd0816",
            sfstorebookie_tag: "base-0000065-340ffbdf",
            lvprovisioner_tag: "v1.0-0000015-0ba0b53a",
            sfnodeprep_tag: "base-0000362-8c6931af",
            loginit_tag: "base-0000362-8c6931af",
        },

        ### Release Phase 2 - prd-sam (control plane), prd-sam_ceph and prd-sam_sfstore
        "2": {
            default_tag: "base-0000362-8c6931af",
            ceph_operator_tag: "base-0000362-8c6931af",
            sfms_tag: "latest-0000151-78ea2ca9",
            cephdaemon_tag: "jewel-0000056-50bd0816",
            sfstorebookie_tag: "base-0000065-340ffbdf",
            lvprovisioner_tag: "v1.0-0000015-0ba0b53a",
            sfnodeprep_tag: "base-0000362-8c6931af",
            loginit_tag: "base-0000362-8c6931af",
        },

        ### Release Phase 3 - Canary sites in Prod (PHX)
        "3": {
            default_tag: "base-0000360-ba0dd469",
            ceph_operator_tag: "base-0000360-ba0dd469",
            sfms_tag: "latest-0000147-e9f9f61c",
            cephdaemon_tag: "jewel-0000056-50bd0816",
            sfstorebookie_tag: "base-0000064-6c5c1cb6",
            lvprovisioner_tag: "v1.0-0000015-0ba0b53a",
            sfnodeprep_tag: "base-0000360-ba0dd469",
            loginit_tag: "base-0000360-ba0dd469",
        },

        ### Release Phase 4 - All Prod. Currently disabled, because there are no other prod clusters yet.
        "4": {
            default_tag: "Disabled",
            },
    },

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-sam_storage" || estate == "prd-skipper") then
            "1"
        else if (kingdom == "prd") then
            "2"
        else if (kingdom == "phx") then
            "3"
        else
            "4"
        ),

    # ====== ONLY CHANGE THE STUFF BELOW WHEN ADDING A NEW IMAGE.  RELEASES SHOULD ONLY INVOLVE CHANGES ABOVE ======

    # These are the images used by the templates.

    # Maintained in https://git.soma.salesforce.com/SFStorage/foundation repo.
    fdscontroller: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "faultdomainset", $.per_phase[$.phase].default_tag),
    configwatcher: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "configwatcher", $.per_phase[$.phase].default_tag),
    sfstoreoperator: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "sfstoreoperator", $.per_phase[$.phase].default_tag),
    alertmanager: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "alertmanager", $.per_phase[$.phase].default_tag),
    sfnstatemetrics: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "sfn-state-metrics", $.per_phase[$.phase].default_tag),
    # TODO(rohit.shekhar) change ceph to cephoperator in foundation codebase, then update ceph below to be cephoperator
    cephoperator: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "ceph", $.per_phase[$.phase].ceph_operator_tag),
    loginit: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "loginitcontainer", $.per_phase[$.phase].loginit_tag),
    nodeprep: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "nodeprep", $.per_phase[$.phase].sfnodeprep_tag),

    # The Metric Streamer is maintained in https://git.soma.salesforce.com/SdbStoreOps/Prod-Operations repo. Therefore, it does not use the default_tag.
    sfms: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "sfms", $.per_phase[$.phase].sfms_tag),

    # The ceph daemon image is maintained in the https://git.soma.salesforce.com/SFStorage/ceph-docker repo.
    cephdaemon: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "ceph-daemon", $.per_phase[$.phase].cephdaemon_tag),
    # cephdaemon_image_path is the base path for daemon images. The tag for the daemon image will come from the ceph cluster spec itself.
    cephdaemon_image_path: std.split($.cephdaemon, ":")[0],
    # ceph_daemon_tag is the tag used for daemon images. This is populated in the ceph cluster spec, and can be overridden per-minion estate
    # via $.overrides (see do_cephdaemon_tag_override in ceph-cluster.jsonnet).
    cephdaemon_tag: $.per_phase[$.phase].cephdaemon_tag,

    # The sfstore bookie image is maintained in the https://git.soma.salesforce.com/SFStorage/bookkeeper repo.
    sfstorebookie: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "bookie", $.per_phase[$.phase].sfstorebookie_tag),

    # The sfstore lvprovisioner image is maintained in the https://git.soma.salesforce.com/SFStorage/lvprovisioner repo.
    lvprovisioner: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "lvprovisioner", $.per_phase[$.phase].lvprovisioner_tag),

    # image_functions needs to know the filename of the template we are processing
    # Each template must set this at time of importing this file, for example:
    #
    # "local someteamimages = (import "someteamimages.jsonnet")  + { templateFilename:: std.thisFile };"
    #
    # Then we pass this again into image_functions at time of import.
    templateFilename:: error "templateFilename must be passed at time of import",
    local imageFunc = (import "image_functions.libsonnet") + { templateFilename:: $.templateFilename },
}
