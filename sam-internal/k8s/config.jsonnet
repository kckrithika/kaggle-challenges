{
local estate = std.extVar("estate"),
local images = import "images.jsonnet",

    perCluster: {
        registry: {
            "prd-sam": "shared0-samcontrol1-1-prd.eng.sfdc.net:5000",
            "prd-samtemp": "shared0-samcontrol1-1-prd.eng.sfdc.net:5000",
            "prd-samdev": "shared0-samdevkubeapi1-1-prd.eng.sfdc.net:5000"
        },

        funnelVIP: {
            "prd-sam": "mandm-funnel-sfz.data.sfdc.net",
            "prd-samtemp": "mandm-funnel-sfz.data.sfdc.net",
            "prd-samdev": "mandm-funnel-sfz.data.sfdc.net"
        }
    }, 

    funnelVIP: self.perCluster.funnelVIP[estate],
    registry: self.perCluster.registry[estate],

    controller: images.controller,
    debug_portal: images.debug_portal,
    watchdog_common: images.watchdog_common,
    watchdog_master: images.watchdog_master,
    watchdog_etcd: images.watchdog_etcd,
    manifest_watcher: images.manifest_watcher,
    slam_agent: images.slam_agent
}
