{
    # Docker images to use for each estate
    # Each estate must have a "default" tag.  If desired, individual docker images can have overrides.
    # Here is the syntax to override controller in foo-sam:
    # "foo-sam": {
    #     default: hypersam:normal-image
    #     controller: hypersam:some-image-being-tested
    # }

    local configs = import "config.jsonnet",

    # ================== SAM RELEASE ====================
    # Releases should follow the order below unless there are special circumstances.  Each phase should use the
    # image from the previous stage after a 24 hour bake time with no issues (check that all watchdog are healthy)

    # Release Phase 1 - Test Beds
    phase1_test: {
      hypersam: "sam-0000832-c5b300e8",
    },

    # Release Phase 2 - PRD Sandbox and prd-sdc
    phase2_sandbox: {
      hypersam: "sam-0000832-c5b300e8",
    },

    # Release Phase 3 - Canary Prod FRF
    phase3_prod_canary: {
      hypersam: "sam-0000823-9d4a0250",
    },

    # Release Phase 4 - Rest of Prod
    phase4_prod_all: {
      hypersam: "sam-0000823-9d4a0250",
    },

    # ====================================================

    # This section is for shared long-lived images (not overrides).  Overrides should live in the per-estate sections below
    # and get removed each time we roll out a default newer than the override.
    testimages: {
        k8sproxy: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/thargrove/haproxy:20170404_084549.17ef285.dirty.thargrove-ltm1",
        permissionInitContainer: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-c07d4afb-673",
        sdn_bird: configs.registry + "/" + "docker-release-candidate/tnrp/sdn/bird:v-0000012-1d22df3a",
        sdn_image: configs.registry + "/" + "docker-release-candidate/tnrp/sdn/hypersdn:v-0000062-f9b0ef9e",
        slb_image: configs.registry + "/" + "docker-release-candidate/tnrp/sdn/hypersdn:v-0000065-8a47eb74",
    },

    # Shared images for all prod beds.  This should be a previously tested image from the sandbox above.
    prodimages: {
        permissionInitContainer: configs.registry + "/" + "tnrp/sam/hypersam:sam-1ebeb0ac-657",
    },

    estates: {
        "prd-sam": {
            # For now we need to keep the root level folder 'docker-release-candidate' because it is needed for promotion
            # even though that is not a required root level directory.  For prod clusters leave this off (it would be
            # different in prod anyways)
            default: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam" + ":" + $.phase2_sandbox.hypersam,
            k8sproxy: $.testimages.k8sproxy,
            permissionInitContainer: $.testimages.permissionInitContainer,
            sdn_bird: $.testimages.sdn_bird,
            sdn_peering_agent: $.testimages.sdn_image,
            sdn_watchdog: $.testimages.sdn_image,

            # Temporary overrides
        },
        "prd-samdev": {
            default: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam" + ":" + $.phase1_test.hypersam,
            k8sproxy: $.testimages.k8sproxy,
            permissionInitContainer: $.testimages.permissionInitContainer,
            sdn_bird: $.testimages.sdn_bird,
            sdn_peering_agent: $.testimages.sdn_image,
            sdn_watchdog: $.testimages.sdn_image,

            # Temporary overrides
        },
        "prd-samtest": {
            default: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam" + ":" + $.phase1_test.hypersam,
            k8sproxy: $.testimages.k8sproxy,
            permissionInitContainer: $.testimages.permissionInitContainer,
            sdn_bird: $.testimages.sdn_bird,
            sdn_peering_agent: $.testimages.sdn_image,
            sdn_watchdog: $.testimages.sdn_image,

            # Temporary overrides
        },
        "prd-sdc": {
            default: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam" + ":" + $.phase2_sandbox.hypersam,
            k8sproxy: $.testimages.k8sproxy,
            permissionInitContainer: $.testimages.permissionInitContainer,
            sdn_bird: $.testimages.sdn_bird,
            sdn_peering_agent: $.testimages.sdn_image,
            sdn_watchdog: $.testimages.sdn_image,
            slb_iface_agent: $.testimages.slb_image,
            slb_ipvs: $.testimages.slb_image,
            slb_realsvrcfg : $.testimages.slb_image,
            slb_config_processor : $.testimages.slb_image,

            # Temporary overrides
            samcontrol_deployer: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-0000807-258dde00",
        },
        "dfw-sam": {
            default: configs.registry + "/" + "tnrp/sam/hypersam" + ":" + $.phase4_prod_all.hypersam,
            permissionInitContainer: $.prodimages.permissionInitContainer,
        },
        "phx-sam": {
            default: configs.registry + "/" + "tnrp/sam/hypersam" + ":" + $.phase4_prod_all.hypersam,
            permissionInitContainer: $.prodimages.permissionInitContainer,
        },
        "frf-sam": {
            default: configs.registry + "/" + "tnrp/sam/hypersam" + ":" + $.phase3_prod_canary.hypersam,
            permissionInitContainer: $.prodimages.permissionInitContainer,
        },
        "par-sam": {
            default: configs.registry + "/" + "tnrp/sam/hypersam" + ":" + $.phase4_prod_all.hypersam,
            permissionInitContainer: $.prodimages.permissionInitContainer,

            # Temporary overrides
            samcontrol_deployer: configs.registry + "/" + "tnrp/sam/hypersam:sam-0000807-258dde00",
        }
    },

    # This break is needed, because above is one fixed portion of output and below is a loop per image
    # Without this break both would become part of the same loop and we would get a collision on 'estates' above
} + {
    # This block will generate flattened output for this estate for each dockerimg
    # It will look for a per-image override above, but failing that it will use the default for the estate
    # NOTE: I tried to make the last line less ugly by moving the array of image names to its own section, but I could not make it work

    local estate = std.extVar("estate"),

    # Loop over dockerimg (controller, debug_portal, etc...)
    #   Key: dockerimg
    #   Value: registry + "/" + ( if estates above has an entry for this estate+dockerimg use it, else use estate+"default" image )
    #
    [dockerimg]: (if std.objectHas($.estates[estate], dockerimg) then $.estates[estate][dockerimg] else $.estates[estate]["default"]) for dockerimg in ["controller", "watchdog", "manifest_watcher","sam_deployment_portal", "k8sproxy", "sdn_bird", "sdn_peering_agent", "sdn_watchdog", "slb_iface_agent", "slb_ipvs", "samcontrol_deployer", "permissionInitContainer", "sam_deployment_reporter", "slb_realsvrcfg", "slb_config_processor"]
}
