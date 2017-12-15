local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local utils = import "util_functions.jsonnet";
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

        // TODO: The SAM deployer currently clobbers custom resource status on updates. Keep the version fixed at `latest` in existing
        //       clusters until either the SAM deployer is fixed to not clobber the status of custom resources or the ceph operator
        //       is fixed to move the cluster state to a separate object.
        "prd,prd-sam_cephdev,ceph-cluster,ceph-daemon": "latest",
        "prd,prd-sam_ceph,ceph-cluster,ceph-daemon": "latest",
    },

    ### Per-phase image tags
    per_phase: {

        ### Release Phase 0 - prd-sam_storage (control plane), prd-sam_cephdev, and prd-sam_sfstoredev
        "0": {
            default_tag: "base-0000284-989c85c6",
            ceph_operator_tag: "base-0000285-7ad9ed5d",
            sfms_tag: "latest-0000089-2f101be4",
            cephdaemon_tag: "jewel-0000052-36e8b39d",
            sfstorebookie_tag: "base-0000021-f9f2ef07",
            lvprovisioner_tag: "v1.0-0000015-0ba0b53a",
            sfnodeprep_tag: "base-0000016-45146d1d",
        },

        ### Release Phase 1 - prd-sam (control plane), prd-sam_ceph and prd-sam_sfstore
        "1": {
            default_tag: "base-0000284-989c85c6",
            ceph_operator_tag: "base-0000284-989c85c6",
            sfms_tag: "latest-0000089-2f101be4",
            cephdaemon_tag: "jewel-0000052-36e8b39d",
            sfstorebookie_tag: "base-0000021-f9f2ef07",
            lvprovisioner_tag: "v1.0-0000015-0ba0b53a",
            sfnodeprep_tag: "base-0000016-45146d1d",
            },

        ### Release Phase 2 - TBD
        "2": {
            default_tag: "base-0000276-0d0bc5c0",
            ceph_operator_tag: "base-0000276-0d0bc5c0",
            sfms_tag: "latest-0000087-bb6bfdee",
            cephdaemon_tag: "jewel-0000052-36e8b39d",
            sfstorebookie_tag: "base-0000021-f9f2ef07",
            lvprovisioner_tag: "v1.0-0000015-0ba0b53a",
            sfnodeprep_tag: "base-0000016-45146d1d",
            },

        ### Release Phase 3 - Canary sites in Prod
        "3": {
            default_tag: "base-0000276-0d0bc5c0",
            ceph_operator_tag: "base-0000276-0d0bc5c0",
            sfms_tag: "latest-0000087-bb6bfdee",
            cephdaemon_tag: "jewel-0000052-36e8b39d",
            sfstorebookie_tag: "base-0000021-f9f2ef07",
            lvprovisioner_tag: "v1.0-0000015-0ba0b53a",
            sfnodeprep_tag: "base-0000016-45146d1d",
            },

        ### Release Phase 4 - All Prod
        "4": {
            default_tag: "",
            },
    },

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-sam_storage") then
            "0"
        else if (estate == "prd-sam") then
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
    fdscontroller: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "faultdomainset", $.per_phase[$.phase].default_tag),
    configwatcher: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "configwatcher", $.per_phase[$.phase].default_tag),
    sfstoreoperator: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "sfstoreoperator", $.per_phase[$.phase].default_tag),
    # TODO(rohit.shekhar) change ceph to cephoperator in foundation codebase, then update ceph below to be cephoperator
    cephoperator: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "ceph", $.per_phase[$.phase].ceph_operator_tag),
    loginit: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "loginitcontainer", $.per_phase[$.phase].default_tag),

    # The Metric Streamer is maintained in https://git.soma.salesforce.com/SdbStoreOps/Prod-Operations repo. Therefore, it does not use the default_tag.
    sfms: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "sfms", $.per_phase[$.phase].sfms_tag),

    # The ceph daemon image is maintained in the https://git.soma.salesforce.com/SFStorage/ceph-docker repo.
    cephdaemon: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "ceph-daemon", $.per_phase[$.phase].cephdaemon_tag),
    # cephdaemon_image_path is the base path for daemon images. The tag for the daemon image will come from the ceph cluster spec itself.
    cephdaemon_image_path: std.split($.cephdaemon, ":")[0],
    # ceph_daemon_tag is the tag used for daemon images. This is populated in the ceph cluster spec, and can be overridden per-minion estate
    # via $.overrides (see do_cephdaemon_tag_override in ceph-cluster.jsonnet).
    cephdaemon_tag: $.per_phase[$.phase].cephdaemon_tag,

    # The sfstore bookie image is maintained in the https://git.soma.salesforce.com/SFStorage/bookkeeper repo.
    sfstorebookie: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "bookie", $.per_phase[$.phase].sfstorebookie_tag),

    # The sfstore lvprovisioner image is maintained in the https://git.soma.salesforce.com/SFStorage/lvprovisioner repo.
    lvprovisioner: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "lvprovisioner", $.per_phase[$.phase].lvprovisioner_tag),

    # The sfstore nodeprep image is maintained in the https://git.soma.salesforce.com/SFStorage/nodeprep repo.
    sfnodeprep: utils.do_override_for_tnrp_image($.overrides, "storagecloud", "sfnodeprep", $.per_phase[$.phase].sfnodeprep_tag),
}
