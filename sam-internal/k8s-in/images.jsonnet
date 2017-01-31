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
            default: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/hypersam:sam-cd52c792-543",
            k8sproxy: configs.registry + "/" + "haproxy:10e016e.clean.mayankkuma-ltm3.20161216_011113",
        },
        "prd-samdev": {
            # Figuring out the right docker URL here is tricky.
            # See https://git.soma.salesforce.com/sam/sam/wiki/Official-Secure-Docker-Registry#mapping-artifactory-urls-to-docker-urls
            # Make sure this is ops0-artifactrepo2-0-prd ... /docker-release-candidate/ ...
            #
            default: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/hypersam:sam-cd52c792-543",
            k8sproxy: configs.registry + "/" + "haproxy:10e016e.clean.mayankkuma-ltm3.20161216_011113",
        },
        "prd-sdc": {
            # Switch this to use artifactrepo as soon as we move to centos 7
            default: configs.registry + "/" + "hypersam:sam-cd52c792-543",
            sdc_bird: configs.registry + "/" + "sdc-bird:pporwal-201701292135",
            sdc_peering_agent: configs.registry + "/" + "sdc-peering-agent:pporwal-201701292249",
        },
        "dfw-sam": {
            # Switch this to use artifactrepo as soon as we move to centos 7
            default: configs.registry + "/" + "hypersam:ce3affd",
        },
        "phx-sam": {
            default: configs.registry + "/" + "docker-all/tnrp/sam/hypersam:sam-9db6a3ff-515"
        },
        "frf-sam": {
            default: configs.registry + "/" + "docker-all/tnrp/sam/hypersam:sam-9db6a3ff-515"
        },
        "par-sam": {
            default: configs.registry + "/" + "docker-all/tnrp/sam/hypersam:sam-9db6a3ff-515"
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
    [dockerimg]: (if std.objectHas($.estates[estate], dockerimg) then $.estates[estate][dockerimg] else $.estates[estate]["default"]) for dockerimg in ["controller", "watchdog_common", "watchdog_master", "watchdog_etcd", "manifest_watcher", "k8sproxy", "sdc_bird", "sdc_peering_agent"]
}

