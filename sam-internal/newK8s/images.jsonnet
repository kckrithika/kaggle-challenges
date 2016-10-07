{
local configs = import "config.jsonnet",
local estate = std.extVar("estate"),

    "controller": {
        "prd-sam": configs.registry[estate]+"/sam-controller:mayank.kumar-20160914_145440-cfc3f85a",
        "prd-samtemp": configs.registry[estate]+"/sam-controller:mayank.kumar-20160914_145440-cfc3f85a"
    },
    "debug_portal": {
        "prd-sam": configs.registry[estate]+"/debug-portal:thargrove-20160811_134228-c36dfe9",
        "prd-samtemp": configs.registry[estate]+"/debug-portal:thargrove-20160811_134228-c36dfe9"
    },
    "watchdog_common": {
        "prd-sam": configs.registry[estate]+"/watchdog:prabh.singh-20160920_234757-7f22ddd",
        "prd-samtemp": configs.registry[estate]+"/watchdog:prabh.singh-20160920_234757-7f22ddd"
    },
    "watchdog_master": {
        "prd-sam": configs.registry[estate]+"/watchdog:prabh.singh-20160920_234757-7f22ddd",
        "prd-samtemp": configs.registry[estate]+"/watchdog:prabh.singh-20160920_234757-7f22ddd"
    },
    "watchdog_etcd": {
        "prd-sam": configs.registry[estate]+"/watchdog:prabh.singh-20160920_234757-7f22ddd",
        "prd-samtemp": configs.registry[estate]+"/watchdog:prabh.singh-20160920_234757-7f22ddd"
    },
    "manifest_watcher": {
        "prd-sam": configs.registry[estate]+"/manifest-watcher:thargrove-20160914_133157-a8d65",
        "prd-samtemp": configs.registry[estate]+"/manifest-watcher:thargrove-20160914_133157-a8d65"
    },
    "slam_agent": {
        "prd-sam": configs.registry[estate]+"/slam-agent:v2.1",
        "prd-samtemp": configs.registry[estate]+"/slam-agent:v2.1"
    }
}
