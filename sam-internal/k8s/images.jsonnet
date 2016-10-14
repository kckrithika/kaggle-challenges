{
local configs = import "config.jsonnet",
local estate = std.extVar("estate"),

    tags: {
        controller: {
            "prd-sam": "hypersam:xiao.zhou-20161014_115059-562cfb7",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b",
            "prd-samdev": "hypersam:mayank.kumar-20161012_171032-4d812c3",
            },
        "debug_portal": {
            "prd-sam": "hypersam:xiao.zhou-20161014_115059-562cfb7",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b",
            "prd-samdev": "hypersam:mayank.kumar-20161012_171032-4d812c3",
            },
        "watchdog_common": {
            "prd-sam": "hypersam:xiao.zhou-20161014_115059-562cfb7",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b",
            "prd-samdev": "hypersam:mayank.kumar-20161012_171032-4d812c3",
        },
        "watchdog_master": {
            "prd-sam": "hypersam:xiao.zhou-20161014_115059-562cfb7",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b",
            "prd-samdev": "hypersam:mayank.kumar-20161012_171032-4d812c3",
        },
        "watchdog_etcd": {
            "prd-sam": "hypersam:xiao.zhou-20161014_115059-562cfb7",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b",
            "prd-samdev": "hypersam:mayank.kumar-20161012_171032-4d812c3",
        },
        "manifest_watcher": {
            "prd-sam": "hypersam:xiao.zhou-20161014_115059-562cfb7",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b",
            "prd-samdev": "hypersam:mayank.kumar-20161012_171032-4d812c3",
        },
        "slam_agent": {
            "prd-sam": "hypersam:xiao.zhou-20161014_115059-562cfb7",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b",
            "prd-samdev": "hypersam:mayank.kumar-20161012_171032-4d812c3",
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
