{
local configs = import "config.jsonnet",
local estate = std.extVar("estate"),

    tags: {
        controller: {
            "prd-sam": "sam-controller:mayank.kumar-20160914_145440-cfc3f85a",
            "prd-samtemp": "sam-controller:mayank.kumar-20160914_145440-cfc3f85a"
            },
        "debug_portal": {
            "prd-sam": "debug-portal:thargrove-20160811_134228-c36dfe9",
            "prd-samtemp": "debug-portal:thargrove-20160811_134228-c36dfe9"
            },
        "watchdog_common": {
            "prd-sam": "watchdog:prabh.singh-20160920_234757-7f22ddd",
            "prd-samtemp": "watchdog:prabh.singh-20160920_234757-7f22ddd"
        },
        "watchdog_master": {
            "prd-sam": "watchdog:prabh.singh-20160920_234757-7f22ddd",
            "prd-samtemp": "watchdog:prabh.singh-20160920_234757-7f22ddd"
        },
        "watchdog_etcd": {
            "prd-sam": "watchdog:prabh.singh-20160920_234757-7f22ddd",
            "prd-samtemp": "watchdog:prabh.singh-20160920_234757-7f22ddd"
        },
        "manifest_watcher": {
            "prd-sam": "manifest-watcher:thargrove-20160914_133157-a8d65",
            "prd-samtemp": "manifest-watcher:thargrove-20160914_133157-a8d65"
        },
        "slam_agent": {
            "prd-sam": "slam-agent:v2.1",
            "prd-samtemp": "slam-agent:v2.1"
        }
    },

#################DO NOT EDIT BELOW THIS LINE #################

    controller: configs.registry + "/" +  self.tags.controller[estate],

    debug_portal: configs.registry + "/" +  self.tags.debug_portal[estate],

    watchdog_common: configs.registry + "/" +  self.tags.watchdog_common[estate],

    watchdog_master: configs.registry + "/" +  self.tags.watchdog_master[estate],

    watchdog_etcd: configs.registry + "/" +  self.tags.watchdog_etcd[estate],

    manifest_watcher: configs.registry + "/" +  self.tags.manifest_watcher[estate],

    slam_agent: configs.registry + "/" +  self.tags.slam_agent[estate]
    
}
