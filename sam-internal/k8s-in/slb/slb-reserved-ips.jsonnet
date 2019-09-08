{
    local set_value_to_all_in_list(value, list) = { [item]: value for item in list },
    local set_value_to_all_in_list_skip(value, list, skip) = { [item]: value for item in list if item != skip },

    prodKingdoms: ['frf', 'phx', 'iad', 'ord', 'dfw', 'hnd', 'xrd', 'cdg', 'fra', 'ia2', 'ph2', 'par', 'ukb', 'lo2', 'lo3'],
    slbKingdoms: $.prodKingdoms + ["prd"],
    prodEstates: [k + "-sam" for k in $.slbKingdoms] + ['prd-samtwo'],
    testEstates: ['prd-sdc', 'prd-samdev', 'prd-samtest', 'prd-sam_storage'],

    publicReservedIps:
        set_value_to_all_in_list([], $.testEstates)
        + set_value_to_all_in_list([], $.prodEstates)
        + {
            "cdg-sam": [
              "85.222.142.5/32",  # slb-canary-proxy-http-ext.sam-system.cdg-sam.cdg.slb.sfdc.net
            ],
            "dfw-sam": [
              "13.110.28.11/32",  # gs0-bofa-dfw.slb.sfdc.net
              "13.110.28.5/32",  # slb-canary-proxy-http-ext.sam-system.dfw-sam.dfw.slb.sfdc.net
              "13.110.28.12/32",  # login-cloudforce-dfw.slb.sfdc.net
              "13.110.28.13/32",  # sledge-dfw.slb.sfdc.net
              "13.110.28.101/32",  # org-cce2e-cs3-slb-dfw.slb.sfdc.net
              "13.110.28.102/32",  # org-cce2e-cs7-slb-dfw.slb.sfdc.net
              "13.110.28.103/32",  # org-cce2e-cs9-slb-dfw.slb.sfdc.net
              "13.110.28.104/32",  # org-cce2e-cs10-slb-dfw.slb.sfdc.net
              "13.110.28.105/32",  # org-cce2e-cs11-slb-dfw.slb.sfdc.net
              "13.110.28.106/32",  # org-cce2e-cs12-slb-dfw.slb.sfdc.net
              "13.110.28.107/32",  # org-cce2e-cs13-slb-dfw.slb.sfdc.net
              "13.110.28.108/32",  # org-cce2e-cs19-slb-dfw.slb.sfdc.net
              "13.110.28.109/32",  # org-cce2e-cs20-slb-dfw.slb.sfdc.net
              "13.110.28.110/32",  # org-cce2e-cs21-slb-dfw.slb.sfdc.net
              "13.110.28.111/32",  # org-cce2e-cs23-slb-dfw.slb.sfdc.net
              "13.110.28.112/32",  # org-cce2e-cs25-slb-dfw.slb.sfdc.net
              "13.110.28.113/32",  # org-cce2e-cs26-slb-dfw.slb.sfdc.net
              "13.110.28.114/32",  # org-cce2e-cs30-slb-dfw.slb.sfdc.net
              "13.110.28.115/32",  # org-cce2e-cs50-slb-dfw.slb.sfdc.net
              "13.110.28.116/32",  # org-cce2e-cs51-slb-dfw.slb.sfdc.net
              "13.110.28.117/32",  # org-cce2e-cs52-slb-dfw.slb.sfdc.net
              "13.110.28.118/32",  # org-cce2e-cs53-slb-dfw.slb.sfdc.net
              "13.110.28.119/32",  # org-cce2e-cs54-slb-dfw.slb.sfdc.net
              "13.110.28.120/32",  # org-cce2e-cs59-slb-dfw.slb.sfdc.net
              "13.110.28.121/32",  # org-cce2e-cs60-slb-dfw.slb.sfdc.net
              "13.110.28.122/32",  # org-cce2e-cs61-slb-dfw.slb.sfdc.net
              "13.110.28.123/32",  # org-cce2e-cs62-slb-dfw.slb.sfdc.net
              "13.110.28.124/32",  # org-cce2e-cs63-slb-dfw.slb.sfdc.net
              "13.110.28.125/32",  # org-cce2e-cs68-slb-dfw.slb.sfdc.net
              "13.110.28.126/32",  # org-cce2e-cs69-slb-dfw.slb.sfdc.net
              "13.110.28.127/32",  # org-cce2e-cs70-slb-dfw.slb.sfdc.net
              "13.110.28.128/32",  # org-cce2e-cs71-slb-dfw.slb.sfdc.net
              "13.110.28.129/32",  # org-cce2e-cs90-slb-dfw.slb.sfdc.net
              "13.110.28.130/32",  # org-cce2e-cs91-slb-dfw.slb.sfdc.net
              "13.110.28.131/32",  # org-cce2e-cs999-slb-dfw.slb.sfdc.net
            ],
            "fra-sam": [
              "85.222.140.16/32",  # cs103app-lb.core-on-sam-sp1.fra-sam.fra.slb.sfdc.net
              "85.222.140.17/32",  # cs103app-force-lb.core-on-sam-sp1.fra-sam.fra.slb.sfdc.net
              "85.222.140.18/32",  # cs103app-my-lb.core-on-sam-sp1.fra-sam.fra.slb.sfdc.net
              "85.222.140.5/32",  # slb-canary-proxy-http-ext.sam-system.fra-sam.fra.slb.sfdc.net
             ],
            "frf-sam": [
              "185.79.140.14/32",  # rsui-production-frf-lb.retail-rsui.frf-sam.frf.slb.sfdc.net
              "185.79.140.15/32",  # rsui-production-frf-test-lb.retail-rsui.frf-sam.frf.slb.sfdc.net
              "185.79.140.5/32",  # slb-canary-proxy-http-ext.sam-system.frf-sam.frf.slb.sfdc.net
              "185.79.140.13/32",  # sledge-frf.slb.sfdc.net
            ],
            "par-sam": [
              "185.79.142.14/32",  # rsui-production-par-lb.retail-rsui.par-sam.par.slb.sfdc.net
              "185.79.142.15/32",  # rsui-production-par-test-lb.retail-rsui.par-sam.par.slb.sfdc.net
              "185.79.142.13/32",  # sledge-par.slb.sfdc.net
            ],
            "ph2-sam": [
              "13.110.52.5/32",  # slb-canary-proxy-http-ext.sam-system.ph2-sam.ph2.slb.sfdc.net
            ],
            "phx-sam": [
              "13.110.30.5/32",  # slb-canary-proxy-http-ext.sam-system.phx-sam.phx.slb.sfdc.net
              "13.110.30.11/32",  # gs0-bofa-phx.slb.sfdc.net
              "13.110.30.12/32",  # login-cloudforce-phx.slb.sfdc.net
              "13.110.30.13/32",  # sledge-phx.slb.sfdc.net
            ],
            "prd-samtwo": [
              "136.146.214.8/32",  #na44-stmfa1-0-prd.slb.sfdc.net
              "136.146.214.9/32",  #na44-stmfb1-0-prd.slb.sfdc.net
              "136.146.214.10/32",  #na44-stmfc1-0-prd.slb.sfdc.net
              "136.146.214.5/32",  # slb-canary-proxy-http-ext.sam-system.prd-samtwo.prd.slb.sfdc.net
            ],
            # C360 -- start -- W-6124538
            "iad-sam": [
              "13.110.24.14/32",  # rsui-production-iad-lb.retail-rsui.iad-sam.iad.slb.sfdc.net
              "13.110.24.15/32",  # rsui-production-iad-test-lb.retail-rsui.iad-sam.iad.slb.sfdc.net
              "13.110.24.5/32",  # slb-canary-proxy-http-ext.sam-system.iad-sam.iad.slb.sfdc.net
              "13.110.24.13/32",  # sledge-iad.slb.sfdc.net
            ],
            "ord-sam": [
              "13.110.26.14/32",  # rsui-production-ord-lb.retail-rsui.ord-sam.ord.slb.sfdc.net
              "13.110.26.15/32",  # rsui-production-ord-test-lb.retail-rsui.ord-sam.ord.slb.sfdc.net
              "13.110.26.5/32",  # slb-canary-proxy-http-ext.sam-system.iad-sam.iad.slb.sfdc.net
              "13.110.26.13/32",  # sledge-iad.slb.sfdc.net
            ],
            # C360 -- end
            "ukb-sam": [
              "161.71.146.14/32",  # rsui-production-ukb-lb.retail-rsui.ukb-sam.ukb.slb.sfdc.net
              "161.71.146.15/32",  # rsui-production-ukb-test-lb.retail-rsui.ukb-sam.ukb.slb.sfdc.net
              "161.71.146.13/32",  # sledge-ukb.slb.sfdc.net
            ],
            "hnd-sam": [
              "161.71.144.14/32",  # rsui-production-hnd-lb.retail-rsui.hnd-sam.hnd.slb.sfdc.net
              "161.71.144.15/32",  # rsui-production-hnd-test-lb.retail-rsui.hnd-sam.hnd.slb.sfdc.net
              "161.71.144.5/32",  # slb-canary-proxy-http-ext.sam-system.hnd-sam.hnd.slb.sfdc.net
              "161.71.144.13/32",  # sledge-hnd.slb.sfdc.net
            ],
        },

        privateReservedIps:
            set_value_to_all_in_list([], $.testEstates)
            + set_value_to_all_in_list([], $.prodEstates)
            + {
                "dfw-sam": [
                  "10.214.188.141/32",  # sec0-magister1-0-dfw.slb.sfdc.net
                ],
                "frf-sam": [
                  "10.214.36.129/32",  # kubernetes-api-flowsnake-frf.slb.sfdc.net
                  "10.214.36.14/32",  #cre-control-plane-lb.retail-cre.frf-sam.frf.slb.sfdc.net
                  "10.214.36.140/32",  #cre-sp-lb.retail-cre.frf-sam.frf.slb.sfdc.net
                  "10.214.36.144/32",  #cre-api-lb.retail-cre.par-sam.frf.slb.sfdc.net
                  "10.214.36.146/32",  #metadata-service-lb.retail-mds.frf-sam.frf.slb.sfdc.net
                  "10.214.36.141/32",  #dfs-production-lb.retail-dfs.frf-sam.frf.slb.sfdc.net
                  "10.214.36.145/32",  #rsui-service-frf-lb.retail-rsui.frf-sam.frf.slb.sfdc.net
                ],
                "par-sam": [
                  "10.214.112.129/32",  # kubernetes-api-flowsnake-par.slb.sfdc.net
                  "10.214.112.103/32",  #cre-control-plane-lb.retail-cre.par-sam.par.slb.sfdc.net
                  "10.214.112.107/32",  #cre-sp-lb.retail-cre.par-sam.par.slb.sfdc.net
                  "10.214.112.124/32",  #cre-api-lb.retail-cre.par-sam.par.slb.sfdc.net
                  "10.214.112.131/32",  #metadata-service-lb.retail-mds.par-sam.par.slb.sfdc.net
                  "10.214.112.132/32",  #dfs-production-lb.retail-dfs.par-sam.par.slb.sfdc.net
                  "10.214.112.135/32",  #rsui-service-par-lb.retail-rsui.par-sam.par.slb.sfdc.net
                ],
                "phx-sam": [
                  "10.208.208.144/32",  # sec0-magister1-0-phx.slb.sfdc.net.
                ],
                "prd-sam": [
                  "10.251.196.42/32",  # rsui-func-lb.retail-rsui.prd-sam.prd.slb.sfdc.net
                  "10.251.196.44/32",  # rsui-perf-lb.retail-rsui.prd-sam.prd.slb.sfdc.net
                  "10.251.197.44/32",  # ops0-dvaregistryssl1-0-prd.slb.sfdc.net
                  "10.251.196.212/32",  # gatekeeper-dashboardlb.gatekeeper.prd-sam.prd.slb.sfdc.net - Peijun Wu - https://computecloud.slack.com/archives/C42SAQVS9/p1556063807120000?thread_ts=1556038442.093300&cid=C42SAQVS9
                  "10.251.196.113/32",  # ops0-netlog1-0-prd.slb.sfdc.net - Zack Mady - https://computecloud.slack.com/archives/C42SAQVS9/p1556121900123900
                  "10.251.196.117/32",  # codecov.moe.prd-sam.prd.slb.sfdc.net
                ],
                # C360 -- start -- W-6124538
                "iad-sam": [
                  "10.208.108.100/32",  # cre-api-lb.retail-cre.iad-sam.iad.slb.sfdc.net
                  "10.208.108.10/32",  # cre-control-plane-lb.retail-cre.iad-sam.iad.slb.sfdc.net
                  "10.208.108.107/32",  # cre-sp-lb.retail-cre.iad-sam.iad.slb.sfdc.net
                  "10.208.108.148/32",  # dfs-production-lb.retail-dfs.iad-sam.iad.slb.sfdc.net
                  "10.208.108.14/32",  # metadata-service-lb.retail-mds.iad-sam.iad.slb.sfdc.net
                  "10.208.108.15/32",  #rsui-service-iad-lb.retail-rsui.iad-sam.iad.slb.sfdc.net
                ],
                "ord-sam": [
                  "10.208.148.0/32",  # cre-api-lb.retail-cre.ord-sam.ord.slb.sfdc.net
                  "10.208.148.11/32",  # cre-control-plane-lb.retail-cre.ord-sam.ord.slb.sfdc.net
                  "10.208.148.110/32",  # cre-sp-lb.retail-cre.ord-sam.ord.slb.sfdc.net
                  "10.208.148.148/32",  # dfs-production-lb.retail-dfs.ord-sam.ord.slb.sfdc.net
                  "10.208.148.147/32",  # metadata-service-lb.retail-mds.ord-sam.ord.slb.sfdc.net
                  "10.208.148.109/32",  #rsui-service-ord-lb.retail-rsui.ord-sam.ord.slb.sfdc.net
                ],
                # C360 -- end
                "ukb-sam": [
                  "10.213.36.109/32",  #cre-control-plane-lb.retail-cre.ukb-sam.ukb.slb.sfdc.net
                  "10.213.36.117/32",  #cre-sp-lb.retail-cre.ukb-sam.ukb.slb.sfdc.net
                  "10.213.36.125/32",  #cre-api-lb.retail-cre.par-sam.ukb.slb.sfdc.net
                  "10.213.36.126/32",  #metadata-service-lb.retail-mds.ukb-sam.ukb.slb.sfdc.net
                  "10.213.36.121/32",  #dfs-production-lb.retail-dfs.ukb-sam.ukb.slb.sfdc.net
                  "10.213.36.122/32",  #rsui-service-ukb-lb.retail-rsui.ukb-sam.ukb.slb.sfdc.net
                ],
                "hnd-sam": [
                  "10.213.100.136/32",  #cre-control-plane-lb.retail-cre.hnd-sam.hnd.slb.sfdc.net
                  "10.213.100.137/32",  #cre-sp-lb.retail-cre.hnd-sam.hnd.slb.sfdc.net
                  "10.213.100.14/32",  #cre-api-lb.retail-cre.par-sam.hnd.slb.sfdc.net
                  "10.213.100.140/32",  #metadata-service-lb.retail-mds.hnd-sam.hnd.slb.sfdc.net
                  "10.213.100.138/32",  #dfs-production-lb.retail-dfs.hnd-sam.hnd.slb.sfdc.net
                  "10.213.100.139/32",  #rsui-service-hnd-lb.retail-rsui.hnd-sam.hnd.slb.sfdc.net
                ],
            },
}
