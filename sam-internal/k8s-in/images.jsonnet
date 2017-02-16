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
            default: configs.registry + "/" + "tnrp/sam/hypersam:sam-6acc29a7-604",
            k8sproxy: "shared0-samcontrol1-1-prd.eng.sfdc.net:5000/haproxy:10e016e.clean.mayankkuma-ltm3.20161216_011113",
            sam_deployment_portal: "shared0-samcontrol1-1-prd.eng.sfdc.net:5000/hypersam:20170216_141910.cab5aa4.dirty.cbatra-ltm",
        },
        "prd-samdev": {
            default: configs.registry + "/" + "tnrp/sam/hypersam:sam-6acc29a7-604",
            k8sproxy: "shared0-samdevkubeapi1-1-prd.eng.sfdc.net:5000/haproxy:10e016e.clean.mayankkuma-ltm3.20161216_011113",
            watchdog: configs.registry + "/" + "tnrp/sam/hypersam:sam-6acc29a7-604",
        },
        "prd-sdc": {
            # Switch this to use artifactrepo as soon as we move to centos 7
            default: "shared0-sdcsamkubeapi1-1-prd.eng.sfdc.net:5000/hypersam:20170214_142452.2b39d74.dirty.agajjala-ltm5",
            k8sproxy: "shared0-sdcsamkubeapi1-1-prd.eng.sfdc.net:5000/haproxy:10e016e.clean.mayankkuma-ltm3.20161216_011113",
            watchdog: configs.registry + "/" + "tnrp/sam/hypersam:sam-2b0f4665-588",
            sdc_bird: "shared0-sdcsamkubeapi1-1-prd.eng.sfdc.net:5000/sdc-bird:agajjala-201702082334",
            sdc_peering_agent: "shared0-sdcsamkubeapi1-1-prd.eng.sfdc.net:5000/sdc-peering-agent:agajjala-201702082327",
            sdc_metrics: "shared0-sdcsamkubeapi1-1-prd.eng.sfdc.net:5000/sdc-metrics:agajjala-201702082327",
        },
        "dfw-sam": {
            default: configs.registry + "/" + "docker-all/tnrp/sam/hypersam:sam-6acc29a7-604",
        },
        "phx-sam": {
            default: configs.registry + "/" + "docker-all/tnrp/sam/hypersam:sam-6acc29a7-604",
        },
        "frf-sam": {
            default: configs.registry + "/" + "docker-all/tnrp/sam/hypersam:sam-6acc29a7-604",
        },
        "par-sam": {
            default: configs.registry + "/" + "docker-all/tnrp/sam/hypersam:sam-6acc29a7-604",
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
    [dockerimg]: (if std.objectHas($.estates[estate], dockerimg) then $.estates[estate][dockerimg] else $.estates[estate]["default"]) for dockerimg in ["controller", "watchdog", "manifest_watcher","sam_deployment_portal", "k8sproxy", "sdc_bird", "sdc_peering_agent", "sdc_metrics"]
}

