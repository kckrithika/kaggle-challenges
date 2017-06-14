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
    #
    # https://git.soma.salesforce.com/sam/sam/wiki/Deploy-SAM

    # Release Phase 1 - Test Beds
    phase1_test: {
      hypersam: "sam-0000934-6f12a434",
    },

    # Release Phase 2 - PRD Sandbox and prd-sdc
    phase2_sandbox: {
      hypersam: "sam-0000934-6f12a434",
    },

    # Release Phase 3 - Canary Prod FRF
    phase3_prod_canary: {
      hypersam: "sam-0000934-6f12a434",
    },

    # Release Phase 4 - Rest of Prod
    phase4_prod_all: {
      hypersam: "sam-0000921-2e7e2318",
    },

    # ================== SDN RELEASE ====================
    # Releases should follow the order below unless there are special circumstances.  Each phase should use the
    # image from the previous stage after a 24 hour bake time with no issues (check that all watchdog are healthy)

    phase1_prdsdc: {
      hypersdn: "v-0000133-6a6e44d7",
      sdn_bird: "v-0000014-b0a5951d",
      slb: "v-0000146-e0248107"
    },

    # Release to rest of the SAM clusters
    phase2_sam: {
      hypersdn: "v-0000133-6a6e44d7",
      sdn_bird: "v-0000014-b0a5951d",
      slb: "v-0000145-58fce058"
    },

    # This section is for shared long-lived images (not overrides).  Overrides should live in the per-estate sections below
    # and get removed each time we roll out a default newer than the override.
    testimages: {
        k8sproxy: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/thargrove/haproxy:20170404_084549.17ef285.dirty.thargrove-ltm1",
        permissionInitContainer: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-c07d4afb-673",
        sdn_image: configs.registry + "/" + "docker-release-candidate/tnrp/sdn/hypersdn",
        sdn_bird: configs.registry + "/" + "docker-release-candidate/tnrp/sdn/bird",
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
            sdn_bird: $.testimages.sdn_bird + ":" + $.phase2_sam.sdn_bird,
            sdn_peering_agent: $.testimages.sdn_image + ":" + $.phase2_sam.hypersdn,
            sdn_ping_watchdog: $.testimages.sdn_image + ":" + $.phase2_sam.hypersdn,
            sdn_route_watchdog: $.testimages.sdn_image + ":" + $.phase2_sam.hypersdn,
            sdn_vault_agent: $.testimages.sdn_image + ":" + $.phase2_sam.hypersdn,
            slb_config_processor : $.testimages.sdn_image + ":" + $.phase2_sam.slb,
            slb_iface_processor: $.testimages.sdn_image + ":" + $.phase2_sam.slb,
            slb_ipvs: $.testimages.sdn_image + ":" + $.phase2_sam.slb,
            slb_realsvrcfg : $.testimages.sdn_image + ":" + $.phase2_sam.slb,
        },
        "prd-samdev": {
            default: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam" + ":" + $.phase1_test.hypersam,
            k8sproxy: $.testimages.k8sproxy,
            permissionInitContainer: $.testimages.permissionInitContainer,
            sdn_bird: $.testimages.sdn_bird + ":" + $.phase2_sam.sdn_bird,
            sdn_peering_agent: $.testimages.sdn_image + ":" + $.phase2_sam.hypersdn,
            sdn_ping_watchdog: $.testimages.sdn_image + ":" + $.phase2_sam.hypersdn,
            sdn_route_watchdog: $.testimages.sdn_image + ":" + $.phase2_sam.hypersdn,
            sdn_vault_agent: $.testimages.sdn_image + ":" + $.phase2_sam.hypersdn,
            slb_config_processor : $.testimages.sdn_image + ":" + $.phase2_sam.slb,
            slb_iface_processor: $.testimages.sdn_image + ":" + $.phase2_sam.slb,
            slb_ipvs: $.testimages.sdn_image + ":" + $.phase2_sam.slb,
            slb_realsvrcfg : $.testimages.sdn_image + ":" + $.phase2_sam.slb,
        },
        "prd-samtest": {
            default: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam" + ":" + $.phase1_test.hypersam,
            k8sproxy: $.testimages.k8sproxy,
            permissionInitContainer: $.testimages.permissionInitContainer,
            sam_secret_agent: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-0000901-82ac08ff",
            sdn_bird: $.testimages.sdn_bird + ":" + $.phase2_sam.sdn_bird,
            sdn_peering_agent: $.testimages.sdn_image + ":" + $.phase2_sam.hypersdn,
            sdn_ping_watchdog: $.testimages.sdn_image + ":" + $.phase2_sam.hypersdn,
            sdn_route_watchdog: $.testimages.sdn_image + ":" + $.phase2_sam.hypersdn,
            sdn_vault_agent: $.testimages.sdn_image + ":" + $.phase2_sam.hypersdn,
            slb_config_processor : $.testimages.sdn_image + ":" + $.phase2_sam.slb,
            slb_iface_processor: $.testimages.sdn_image + ":" + $.phase2_sam.slb,
            slb_ipvs: $.testimages.sdn_image + ":" + $.phase2_sam.slb,
            slb_realsvrcfg : $.testimages.sdn_image + ":" + $.phase2_sam.slb,
        },
        "prd-sdc": {
            default: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam" + ":" + $.phase2_sandbox.hypersam,
            k8sproxy: $.testimages.k8sproxy,
            permissionInitContainer: $.testimages.permissionInitContainer,
            sam_secret_agent: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-0000901-82ac08ff",
            sdn_bird: $.testimages.sdn_bird + ":" + $.phase1_prdsdc.sdn_bird,
            sdn_peering_agent: $.testimages.sdn_image + ":" + $.phase1_prdsdc.hypersdn,
            sdn_ping_watchdog: $.testimages.sdn_image + ":" + $.phase1_prdsdc.hypersdn,
            sdn_route_watchdog: $.testimages.sdn_image + ":" + $.phase1_prdsdc.hypersdn,
            sdn_vault_agent: $.testimages.sdn_image + ":" + $.phase1_prdsdc.hypersdn,
            slb_config_processor : $.testimages.sdn_image + ":" + $.phase1_prdsdc.slb,
            slb_iface_processor: $.testimages.sdn_image + ":" + $.phase1_prdsdc.slb,
            slb_ipvs: $.testimages.sdn_image + ":" + $.phase1_prdsdc.slb,
            slb_realsvrcfg : $.testimages.sdn_image + ":" + $.phase1_prdsdc.slb,
            slb_dns_register : $.testimages.sdn_image + ":" + $.phase1_prdsdc.slb,
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
        },
        "yul-sam": {
            default: configs.registry + "/" + "tnrp/sam/hypersam" + ":" + $.phase3_prod_canary.hypersam,
            permissionInitContainer: $.prodimages.permissionInitContainer,
        },
        "yhu-sam": {
            default: configs.registry + "/" + "tnrp/sam/hypersam" + ":" + $.phase3_prod_canary.hypersam,
            permissionInitContainer: $.prodimages.permissionInitContainer,
        },
        "iad-sam": {
            default: configs.registry + "/" + "tnrp/sam/hypersam" + ":" + $.phase4_prod_all.hypersam,
            permissionInitContainer: $.prodimages.permissionInitContainer,
        },
        "ord-sam": {
            default: configs.registry + "/" + "tnrp/sam/hypersam" + ":" + $.phase4_prod_all.hypersam,
            permissionInitContainer: $.prodimages.permissionInitContainer,
        },
        "ukb-sam": {
            default: configs.registry + "/" + "tnrp/sam/hypersam" + ":" + $.phase4_prod_all.hypersam,
            permissionInitContainer: $.prodimages.permissionInitContainer,
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
    [dockerimg]: (if std.objectHas($.estates[estate], dockerimg) then $.estates[estate][dockerimg] else $.estates[estate]["default"]) for dockerimg in ["controller", "watchdog", "manifest_watcher","sam_deployment_portal", "k8sproxy", "sdn_bird", "sdn_peering_agent", "sdn_watchdog", "sdn_ping_watchdog", "sdn_route_watchdog", "sdn_vault_agent", "slb_iface_processor", "slb_ipvs", "slb_dns_register", "samcontrol_deployer", "permissionInitContainer", "sam_deployment_reporter", "slb_realsvrcfg", "slb_config_processor", "sam_secret_agent"]
}
