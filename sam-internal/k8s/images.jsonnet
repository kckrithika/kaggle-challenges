{
local configs = import "config.jsonnet",
local estate = std.extVar("estate"),

    tags: {
        controller: {
            "prd-sam": "sam-controller:thargrove-20160929_113217-f43c024",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b"
            },
        "debug_portal": {
            "prd-sam": "debug-portal:thargrove-20160811_134228-c36dfe9",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b"
            },
        "watchdog_common": {
            "prd-sam": "watchdog:prabh.singh-20160928_013647-b8154bb",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b"
        },
        "watchdog_master": {
            "prd-sam": "watchdog:prabh.singh-20160928_013647-b8154bb",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b"
        },
        "watchdog_etcd": {
            "prd-sam": "watchdog:prabh.singh-20160928_013647-b8154bb",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b"
        },
        "manifest_watcher": {
            "prd-sam": "manifest-watcher:thargrove-20160929_131936-85c8846",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b"
        },
        "slam_agent": {
            "prd-sam": "slam-agent:v2.1",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b"
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
