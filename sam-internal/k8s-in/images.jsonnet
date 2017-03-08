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
            default: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-d71d11c2-645",
            k8sproxy: "shared0-samcontrol1-1-prd.eng.sfdc.net:5000/haproxy:10e016e.clean.mayankkuma-ltm3.20161216_011113",
        },
        "prd-samdev": {
            default: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-d71d11c2-645",
            k8sproxy: "shared0-samdevkubeapi1-1-prd.eng.sfdc.net:5000/haproxy:10e016e.clean.mayankkuma-ltm3.20161216_011113",
        },
        "prd-sdc": {
            # Switch this to use artifactrepo as soon as we move to centos 7
            default: configs.registry + "/" + "docker-release-candidate/tnrp/sam/hypersam:sam-d71d11c2-645",
            k8sproxy: "shared0-sdcsamkubeapi1-1-prd.eng.sfdc.net:5000/haproxy:10e016e.clean.mayankkuma-ltm3.20161216_011113",
            sdc_bird: "shared0-sdcsamkubeapi1-1-prd.eng.sfdc.net:5000/sdc-bird:agajjala-201702082334",
            sdc_peering_agent: "shared0-sdcsamkubeapi1-1-prd.eng.sfdc.net:5000/hypersdc:vkarnati-201703081449",
            sdc_watchdog: "shared0-sdcsamkubeapi1-1-prd.eng.sfdc.net:5000/hypersdc:vkarnati-201703081449"
        },
        "dfw-sam": {
            default: configs.registry + "/" + "tnrp/sam/hypersam:sam-d2931cc1-617",
        },
        "phx-sam": {
            default: configs.registry + "/" + "tnrp/sam/hypersam:sam-d2931cc1-617",
        },
        "frf-sam": {
            default: configs.registry + "/" + "tnrp/sam/hypersam:sam-d2931cc1-617",
        },
        "par-sam": {
            default: configs.registry + "/" + "tnrp/sam/hypersam:sam-d2931cc1-617",
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
    [dockerimg]: (if std.objectHas($.estates[estate], dockerimg) then $.estates[estate][dockerimg] else $.estates[estate]["default"]) for dockerimg in ["controller", "watchdog", "manifest_watcher","sam_deployment_portal", "k8sproxy", "sdc_bird", "sdc_peering_agent", "sdc_watchdog"]
}
