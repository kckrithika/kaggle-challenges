{
    # Docker images to use for each estate
    # Each estate must have a "default" tag.  If desired, individual docker images can have overrides.
    # Here is the syntax to override controller in foo-sam:
    # "foo-sam": {
    #     default: hypersam:normal-image
    #     controller: hypersam:some-image-being-tested
    # }

    estates: {
        "prd-sam": {
            default: "hypersam:xiao.zhou-20161014_115059-562cfb7",
            controller: "hypersam:pporwal-20161014_151902-f114d06",
        },
        "prd-samtemp": {
            default: "hypersam:xiao.zhou-20161011_142245-0b6273b",
            controller: "hypersam:pporwal-20161014_151902-f114d06",
        },
        "prd-samdev": {
            default: "hypersam:mayank.kumar-20161012_171032-4d812c3",
            controller: "hypersam:pporwal-20161014_151902-f114d06",
        },
        "dfw-sam": {
            default: "hypersam:e3155e8",
        },
    },

    # This break is needed, because above is one fixed portion of output and below is a loop per image
    # Without this break both would become part of the same loop and we would get a collision on 'estates' above
} + {
    # This block will generate flattened output for this estate for each dockerimg
    # It will look for a per-image override above, but failing that it will use the default for the estate
    # NOTE: I tried to make the last line less ugly by moving the array of image names to its own section, but I could not make it work

    local configs = import "config.jsonnet",
    local estate = std.extVar("estate"),

    # Loop over dockerimg (controller, debug_portal, etc...)
    #   Key: dockerimg
    #   Value: registry + "/" + ( if estates above has an entry for this estate+dockerimg use it, else use estate+"default" image )
    #
    [dockerimg]: configs.registry + "/" + (if std.objectHas($.estates[estate], dockerimg) then $.estates[estate][dockerimg] else $.estates[estate]["default"]) for dockerimg in ["controller", "watchdog_common", "watchdog_master", "watchdog_etcd", "manifest_watcher"]
}

