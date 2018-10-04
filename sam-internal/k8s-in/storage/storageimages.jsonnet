local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local storageutils = import "storageutils.jsonnet";

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
        "prd,prd-sam,sfn-state-metrics,sfn-state-metrics": "base-0000429-3fbfdcf3"
    },

    // NOTE NOTE NOTE
    //   Temporarily moved here as we phase in new breaking changes to the log init container's command line args.
    //   Once the new version has rolled out to all phases, move back to storageconfig.jsonnet and make it more
    //   generic.
    //
    // log_init_container generates the init container necessary to support propagation of logs to the host.
    // image_name: name of the loginitcontainer docker image.
    // pod_log_path: log path (relative to /var/log/) for logs from the pod.
    // uid: userid for the process writing logs.
    // gid: groupid for the process writing logs.
    // username: username corresponding to uid.
    log_init_container(image_name, pod_log_path, uid, gid, username):: {
        local cmdline = if std.parseInt($.phase) > 1 then
                "-g " + gid + " -u " + uid + " -s " + username + " -l " + pod_log_path
            else
                "-container " + uid + " " + pod_log_path,
        command: [
            "sh",
            "-c",
            "/entrypoint.sh " + cmdline,
        ],
        name: "log-init",
        image: image_name,
        securityContext: {
            privileged: true,
        },
        volumeMounts: storageutils.log_init_volume_mounts(),
        env: [
            {
                name: "KUBEVAR_POD_NAME",
                valueFrom: {
                    fieldRef: {
                        fieldPath: "metadata.name",
                    },
                },
            },
            {
                name: "KUBEVAR_POD_NAMESPACE",
                valueFrom: {
                    fieldRef: {
                        fieldPath: "metadata.namespace",
                    },
                },
            },
        ],
    },

    ### Per-phase image tags
    per_phase: {
        ### Release Phase 0 - prd-sam_storagedev
        "0": {
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fstoragecloud%2Ffaultdomainset&last=10&repo=SFStorage%2Ffoundation
            default_tag: "base-0000449-e953964e",
            ceph_operator_tag: "base-0000449-e953964e",
            loginit_tag: "base-0000449-e953964e",
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fstoragecloud%2Fsfms&last=10&repo=SdbStoreOps%2FProd-Operations
            sfms_tag: "latest-0000186-c6ab91f6",
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fstoragecloud%2Flvprovisioner&last=10&repo=SFStorage%2Flvprovisioner
            lvprovisioner_tag: "v1.0-0000015-0ba0b53a",
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fstoragecloud%2Fbookie&last=10&repo=SFStorage%2Fbookkeeper
            sfstorebookie_tag: "base-0000089-39319751",
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fstoragecloud%2Fceph-daemon&last=10&repo=SFStorage%2Fceph-docker
            cephdaemon_tag: "10.2.7-0000062-6d863283",
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fsam%2Fmadkub&last=10&repo=sam%2Fmadkub
            madkub_tag: "1.0.0-0000061-74e4a7b6",
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fstoragecloud%2Fzookeeper&last=10&repo=SFStorage%2Fzookeeper-docker
            zookeeper_tag: "latest-0000006-9f49608c",
        },

        ### Release Phase 1 - prd-sam_storage (control plane), prd-sam_cephdev, prd-sam_sfstoredev, and prd-skipper (control plane)
        "1": {
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fstoragecloud%2Ffaultdomainset&last=10&repo=SFStorage%2Ffoundation
            default_tag: "base-0000437-311530ce",
            ceph_operator_tag: "base-0000437-311530ce",
            loginit_tag: "base-0000437-311530ce",
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fstoragecloud%2Fsfms&last=10&repo=SdbStoreOps%2FProd-Operations
            sfms_tag: "latest-0000182-ebb4867b",
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fstoragecloud%2Flvprovisioner&last=10&repo=SFStorage%2Flvprovisioner
            lvprovisioner_tag: "v1.0-0000015-0ba0b53a",
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fstoragecloud%2Fbookie&last=10&repo=SFStorage%2Fbookkeeper
            sfstorebookie_tag: "base-0000089-39319751",
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fstoragecloud%2Fceph-daemon&last=10&repo=SFStorage%2Fceph-docker
            cephdaemon_tag: "10.2.7-0000062-6d863283",
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fsam%2Fmadkub&last=10&repo=sam%2Fmadkub
            madkub_tag: "1.0.0-0000061-74e4a7b6",
        },

        ### Release Phase 2 - prd-sam (control plane), prd-sam_ceph, and prd-sam_sfstore
        "2": {
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fstoragecloud%2Ffaultdomainset&last=10&repo=SFStorage%2Ffoundation
            default_tag: "base-0000425-c640b395",
            ceph_operator_tag: "base-0000425-c640b395",
            loginit_tag: "base-0000425-c640b395",
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fstoragecloud%2Fsfms&last=10&repo=SdbStoreOps%2FProd-Operations
            sfms_tag: "latest-0000181-64fa308f",
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fstoragecloud%2Flvprovisioner&last=10&repo=SFStorage%2Flvprovisioner
            lvprovisioner_tag: "v1.0-0000015-0ba0b53a",
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fstoragecloud%2Fbookie&last=10&repo=SFStorage%2Fbookkeeper
            sfstorebookie_tag: "base-0000089-39319751",
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fstoragecloud%2Fceph-daemon&last=10&repo=SFStorage%2Fceph-docker
            cephdaemon_tag: "10.2.7-0000062-6d863283",
            # http://samdrlb.csc-sam.prd-sam.prd.slb.sfdc.net:64122/images?hostname=ops0-artifactrepo1-0-prd.data.sfdc.net&path=%2Ftnrp%2Fsam%2Fmadkub&last=10&repo=sam%2Fmadkub
            madkub_tag: "1.0.0-0000061-74e4a7b6",
        },

        ### Release Phase 3 - Canary sites in Prod (PHX). Disabled on 05/19/2018 -- the Ceph cluster in PHX is being decommissioned.
        "3": {
            default_tag: "Disabled",
        },

        ### Release Phase 4 - All Prod. Currently disabled, because there are no other prod clusters yet.
        "4": {
            default_tag: "Disabled",
        },
    },

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-sam_storagedev") then
            "0"
        else if (estate == "prd-sam_storage" || estate == "prd-skipper") then
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
    zookeeperoperator: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "zookeeperoperator", $.per_phase[$.phase].default_tag),
    sfnstatemetrics: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "sfn-state-metrics", $.per_phase[$.phase].default_tag),
    # TODO(rohit.shekhar) change ceph to cephoperator in foundation codebase, then update ceph below to be cephoperator
    cephoperator: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "ceph", $.per_phase[$.phase].ceph_operator_tag),
    loginit: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "loginitcontainer", $.per_phase[$.phase].loginit_tag),
    nodeprep: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "nodeprep", $.per_phase[$.phase].default_tag),
    nodeprepskipper: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "nodeprep-skipper", $.per_phase[$.phase].default_tag),
    maddogpoddeleter: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "poddeleter", $.per_phase[$.phase].default_tag),

    # The Metric Streamer is maintained in https://git.soma.salesforce.com/SdbStoreOps/Prod-Operations repo. Therefore, it does not use the default_tag.
    sfms: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "sfms", $.per_phase[$.phase].sfms_tag),

    # The ceph daemon image is maintained in the https://git.soma.salesforce.com/SFStorage/ceph-docker repo.
    cephdaemon: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "ceph-daemon", $.per_phase[$.phase].cephdaemon_tag),
    # cephdaemon_image_path is the base path for daemon images. The tag for the daemon image will come from the ceph cluster spec itself.
    cephdaemon_image_path: std.split($.cephdaemon, ":")[0],
    # ceph_daemon_tag is the tag used for daemon images. This is populated in the ceph cluster spec, and can be overridden per-minion estate
    # via $.overrides (see do_cephdaemon_tag_override in ceph-cluster.jsonnet).
    cephdaemon_tag: $.per_phase[$.phase].cephdaemon_tag,

    # The zookeeper image is maintained in the https://git.soma.salesforce.com/SFStorage/zookeeper-docker repo.
    zookeeper: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "zookeeper", $.per_phase[$.phase].zookeeper_tag),

    # The sfstore bookie image is maintained in the https://git.soma.salesforce.com/SFStorage/bookkeeper repo.
    sfstorebookie: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "bookie", $.per_phase[$.phase].sfstorebookie_tag),

    # The sfstore lvprovisioner image is maintained in the https://git.soma.salesforce.com/SFStorage/lvprovisioner repo.
    lvprovisioner: imageFunc.do_override_for_tnrp_image($.overrides, "storagecloud", "lvprovisioner", $.per_phase[$.phase].lvprovisioner_tag),

    madkub_image_path: imageFunc.do_override_based_on_tag($.overrides, "sam", "madkub", $.per_phase[$.phase].madkub_tag),

    # image_functions needs to know the filename of the template we are processing
    # Each template must set this at time of importing this file, for example:
    #
    # "local someteamimages = (import "someteamimages.jsonnet")  + { templateFilename:: std.thisFile };"
    #
    # Then we pass this again into image_functions at time of import.
    templateFilename:: error "templateFilename must be passed at time of import",
    local imageFunc = (import "image_functions.libsonnet") + { templateFilename:: $.templateFilename },
}
