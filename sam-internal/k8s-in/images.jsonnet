{
    # Docker images to use for each estate
    # Each estate must have a "default" tag.  If desired, individual docker images can have overrides.
    # Here is the syntax to override controller in foo-sam:
    # "foo-sam": {
    #     default: hypersam:normal-image
    #     controller: hypersam:some-image-being-tested
    # }

    local configs = import "config.jsonnet",

    estates: {
        "prd-sam": {
            # For now we need to keep the root level folder 'docker-release-candidate' because it is needed for promotion
            # even though that is not a required root level directory.  For prod clusters leave this off (it would be
            # different in prod anyways)
            default: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-c07d4afb-673",
            k8sproxy: "shared0-samcontrol1-1-prd.eng.sfdc.net:5000/haproxy:10e016e.clean.mayankkuma-ltm3.20161216_011113",
            permissionInitContainer: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-c07d4afb-673",
            watchdog: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-0000699-f50ea7de",
        },
        "prd-samdev": {
            default: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-c07d4afb-673",
            k8sproxy: "shared0-samdevkubeapi1-1-prd.eng.sfdc.net:5000/haproxy:10e016e.clean.mayankkuma-ltm3.20161216_011113",
            controller: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-0000716-5041629c",
            permissionInitContainer: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-c07d4afb-673",
        },
        "prd-samtest": {
            default: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-c07d4afb-673",
            k8sproxy: "shared0-samtestkubeapi1-1-prd.eng.sfdc.net:5000/haproxy:10e016e.clean.mayankkuma-ltm3.20161216_011113",
            permissionInitContainer: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-c07d4afb-673",
            samcontrol_deployer: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-0000713-62a8a27b",
        },
        "prd-sdc": {
            # Switch this to use artifactrepo as soon as we move to centos 7
            default: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-1ebeb0ac-657",
            watchdog: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-c07d4afb-673",
            k8sproxy: "shared0-sdcsamkubeapi1-1-prd.eng.sfdc.net:5000/haproxy:10e016e.clean.mayankkuma-ltm3.20161216_011113",
            sdn_bird: configs.registry + "/" + "docker-release-candidate/tnrp/sdn/bird:v-0000006-9a0bd192",
            sdn_peering_agent: configs.registry + "/" + "docker-release-candidate/tnrp/sdn/hypersdn:v-0000005-c5147cde",
            sdn_watchdog: configs.registry + "/" + "docker-release-candidate/tnrp/sdn/hypersdn:v-0000005-c5147cde",
            samcontrol_deployer: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-0000713-62a8a27b",
            permissionInitContainer: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-1ebeb0ac-657",
        },
        "dfw-sam": {
            default: configs.registry + "/" + "tnrp/sam/hypersam:sam-1ebeb0ac-657",
            watchdog: configs.registry + "/" + "tnrp/sam/hypersam:sam-c07d4afb-673",
            permissionInitContainer: configs.registry + "/" + "tnrp/sam/hypersam:sam-1ebeb0ac-657",
        },
        "phx-sam": {
            default: configs.registry + "/" + "tnrp/sam/hypersam:sam-1ebeb0ac-657",
            watchdog: configs.registry + "/" + "tnrp/sam/hypersam:sam-c07d4afb-673",
            permissionInitContainer: configs.registry + "/" + "tnrp/sam/hypersam:sam-1ebeb0ac-657",
        },
        "frf-sam": {
            default: configs.registry + "/" + "tnrp/sam/hypersam:sam-1ebeb0ac-657",
            watchdog: configs.registry + "/" + "tnrp/sam/hypersam:sam-c07d4afb-673",
            permissionInitContainer: configs.registry + "/" + "tnrp/sam/hypersam:sam-1ebeb0ac-657",
        },
        "par-sam": {
            default: configs.registry + "/" + "tnrp/sam/hypersam:sam-c07d4afb-673",
            watchdog: configs.registry + "/" + "tnrp/sam/hypersam:sam-c07d4afb-673",
            permissionInitContainer: configs.registry + "/" + "tnrp/sam/hypersam:sam-1ebeb0ac-657",
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
    [dockerimg]: (if std.objectHas($.estates[estate], dockerimg) then $.estates[estate][dockerimg] else $.estates[estate]["default"]) for dockerimg in ["controller", "watchdog", "manifest_watcher","sam_deployment_portal", "k8sproxy", "sdn_bird", "sdn_peering_agent", "sdn_watchdog", "samcontrol_deployer", "permissionInitContainer"]
}