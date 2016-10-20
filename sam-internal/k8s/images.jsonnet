{
local configs = import "config.jsonnet",
local estate = std.extVar("estate"),
local dfwHypersamTag = "hypersam:e3155e8",

    tags: {
        controller: {
            "prd-sam": "hypersam:xiao.zhou-20161014_115059-562cfb7",
            "prd-samtemp": "hypersam:pporwal-20161014_151902-f114d06",
            "prd-samdev": "hypersam:mayank.kumar-20161012_171032-4d812c3",
            "dfw-sam": dfwHypersamTag,
            },
        "debug_portal": {
            "prd-sam": "hypersam:prahlad.joshi-20161019_160053-3942cd2",
            "prd-samtemp": "hypersam:prahlad.joshi-20161019_160053-3942cd2",
            "prd-samdev": "hypersam:mayank.kumar-20161012_171032-4d812c3",
            "dfw-sam": dfwHypersamTag,
            },
        "watchdog_common": {
            "prd-sam": "hypersam:xiao.zhou-20161014_115059-562cfb7",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b",
            "prd-samdev": "hypersam:mayank.kumar-20161012_171032-4d812c3",
            "dfw-sam": dfwHypersamTag,
        },
        "watchdog_master": {
            "prd-sam": "hypersam:xiao.zhou-20161014_115059-562cfb7",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b",
            "prd-samdev": "hypersam:mayank.kumar-20161012_171032-4d812c3",
            "dfw-sam": dfwHypersamTag,
        },
        "watchdog_etcd": {
            "prd-sam": "hypersam:xiao.zhou-20161014_115059-562cfb7",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b",
            "prd-samdev": "hypersam:mayank.kumar-20161012_171032-4d812c3",
            "dfw-sam": dfwHypersamTag,
        },
        "manifest_watcher": {
            "prd-sam": "hypersam:xiao.zhou-20161014_115059-562cfb7",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b",
            "prd-samdev": "hypersam:mayank.kumar-20161012_171032-4d812c3",
            "dfw-sam": dfwHypersamTag,
        },
        "slam_agent": {
            "prd-sam": "hypersam:xiao.zhou-20161014_115059-562cfb7",
            "prd-samtemp": "hypersam:xiao.zhou-20161011_142245-0b6273b",
            "prd-samdev": "hypersam:mayank.kumar-20161012_171032-4d812c3",
            "dfw-sam": dfwHypersamTag,
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
