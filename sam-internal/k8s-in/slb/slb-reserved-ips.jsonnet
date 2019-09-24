{
    local set_value_to_all_in_list(value, list) = { [item]: value for item in list },
    local set_value_to_all_in_list_skip(value, list, skip) = { [item]: value for item in list if item != skip },

    prodKingdoms: ['frf', 'phx', 'iad', 'ord', 'dfw', 'hnd', 'xrd', 'cdg', 'fra', 'ia2', 'ph2', 'par', 'ukb', 'lo2', 'lo3', 'ia4', 'ia5'],
    slbKingdoms: $.prodKingdoms + ["prd"],
    prodEstates: [k + "-sam" for k in $.slbKingdoms] + ['prd-samtwo'],
    testEstates: ['prd-sdc', 'prd-samdev', 'prd-samtest', 'prd-sam_storage'],

    publicReservedIps:
        set_value_to_all_in_list({}, $.testEstates)
        + set_value_to_all_in_list({}, $.prodEstates)
        + {
            "cdg-sam": {
              "slb-canary-proxy-http-ext.sam-system.cdg-sam.cdg.slb.sfdc.net": "85.222.142.5",
            },
            "dfw-sam": {
              "gs0-bofa-dfw.slb.sfdc.net": "13.110.28.11",
              "slb-canary-proxy-http-ext.sam-system.dfw-sam.dfw.slb.sfdc.net": "13.110.28.5",
              "login-cloudforce-dfw.slb.sfdc.net": "13.110.28.12",
              "sledge-dfw.slb.sfdc.net": "13.110.28.13",
              "org-cce2e-cs3-slb-dfw.slb.sfdc.net": "13.110.28.101",
              "org-cce2e-cs7-slb-dfw.slb.sfdc.net": "13.110.28.102",
              "org-cce2e-cs9-slb-dfw.slb.sfdc.net": "13.110.28.103",
              "org-cce2e-cs10-slb-dfw.slb.sfdc.net": "13.110.28.104",
              "org-cce2e-cs11-slb-dfw.slb.sfdc.net": "13.110.28.105",
              "org-cce2e-cs12-slb-dfw.slb.sfdc.net": "13.110.28.106",
              "org-cce2e-cs13-slb-dfw.slb.sfdc.net": "13.110.28.107",
              "org-cce2e-cs19-slb-dfw.slb.sfdc.net": "13.110.28.108",
              "org-cce2e-cs20-slb-dfw.slb.sfdc.net": "13.110.28.109",
              "org-cce2e-cs21-slb-dfw.slb.sfdc.net": "13.110.28.110",
              "org-cce2e-cs23-slb-dfw.slb.sfdc.net": "13.110.28.111",
              "org-cce2e-cs25-slb-dfw.slb.sfdc.net": "13.110.28.112",
              "org-cce2e-cs26-slb-dfw.slb.sfdc.net": "13.110.28.113",
              "org-cce2e-cs30-slb-dfw.slb.sfdc.net": "13.110.28.114",
              "org-cce2e-cs50-slb-dfw.slb.sfdc.net": "13.110.28.115",
              "org-cce2e-cs51-slb-dfw.slb.sfdc.net": "13.110.28.116",
              "org-cce2e-cs52-slb-dfw.slb.sfdc.net": "13.110.28.117",
              "org-cce2e-cs53-slb-dfw.slb.sfdc.net": "13.110.28.118",
              "org-cce2e-cs54-slb-dfw.slb.sfdc.net": "13.110.28.119",
              "org-cce2e-cs59-slb-dfw.slb.sfdc.net": "13.110.28.120",
              "org-cce2e-cs60-slb-dfw.slb.sfdc.net": "13.110.28.121",
              "org-cce2e-cs61-slb-dfw.slb.sfdc.net": "13.110.28.122",
              "org-cce2e-cs62-slb-dfw.slb.sfdc.net": "13.110.28.123",
              "org-cce2e-cs63-slb-dfw.slb.sfdc.net": "13.110.28.124",
              "org-cce2e-cs68-slb-dfw.slb.sfdc.net": "13.110.28.125",
              "org-cce2e-cs69-slb-dfw.slb.sfdc.net": "13.110.28.126",
              "org-cce2e-cs70-slb-dfw.slb.sfdc.net": "13.110.28.127",
              "org-cce2e-cs71-slb-dfw.slb.sfdc.net": "13.110.28.128",
              "org-cce2e-cs90-slb-dfw.slb.sfdc.net": "13.110.28.129",
              "org-cce2e-cs91-slb-dfw.slb.sfdc.net": "13.110.28.130",
              "org-cce2e-cs999-slb-dfw.slb.sfdc.net": "13.110.28.131",
              "org-cce2e-na47-slb-dfw.slb.sfdc.net": "13.110.28.132",
              "org-certtest-gs0-slb-dfw.slb.sfdc.net": "13.110.28.133",
              "org-certtest-cs997-slb-dfw.slb.sfdc.net": "13.110.28.134",
            },
            "fra-sam": {
              "cs103app-lb.core-on-sam-sp1.fra-sam.fra.slb.sfdc.net": "85.222.140.16",
              "cs103app-force-lb.core-on-sam-sp1.fra-sam.fra.slb.sfdc.net": "85.222.140.17",
              "cs103app-my-lb.core-on-sam-sp1.fra-sam.fra.slb.sfdc.net": "85.222.140.18",
              "slb-canary-proxy-http-ext.sam-system.fra-sam.fra.slb.sfdc.net": "85.222.140.5",
             },
            "frf-sam": {
              "rsui-production-frf-lb.retail-rsui.frf-sam.frf.slb.sfdc.net": "185.79.140.14",
              "rsui-production-frf-test-lb.retail-rsui.frf-sam.frf.slb.sfdc.net": "185.79.140.15",
              "slb-canary-proxy-http-ext.sam-system.frf-sam.frf.slb.sfdc.net": "185.79.140.5",
              "sledge-frf.slb.sfdc.net": "185.79.140.13",
            },
            "par-sam": {
              "rsui-production-par-lb.retail-rsui.par-sam.par.slb.sfdc.net": "185.79.142.14",
              "rsui-production-par-test-lb.retail-rsui.par-sam.par.slb.sfdc.net": "185.79.142.15",
              "sledge-par.slb.sfdc.net": "185.79.142.13",
            },
            "ph2-sam": {
              "slb-canary-proxy-http-ext.sam-system.ph2-sam.ph2.slb.sfdc.net": "13.110.52.5",
              "org-cce2e-cs1-slb-ph2.slb.sfdc.net": "13.110.52.101",
              "org-cce2e-cs2-slb-ph2.slb.sfdc.net": "13.110.52.102",
              "org-cce2e-cs4-slb-ph2.slb.sfdc.net": "13.110.52.103",
              "org-cce2e-cs22-slb-ph2.slb.sfdc.net": "13.110.52.104",
              "org-cce2e-cs24-slb-ph2.slb.sfdc.net": "13.110.52.105",
              "org-cce2e-cs27-slb-ph2.slb.sfdc.net": "13.110.52.106",
              "org-cce2e-cs28-slb-ph2.slb.sfdc.net": "13.110.52.107",
              "org-cce2e-cs29-slb-ph2.slb.sfdc.net": "13.110.52.108",
              "org-cce2e-cs34-slb-ph2.slb.sfdc.net": "13.110.52.109",
              "org-cce2e-cs35-slb-ph2.slb.sfdc.net": "13.110.52.110",
              "org-cce2e-cs36-slb-ph2.slb.sfdc.net": "13.110.52.111",
              "org-cce2e-cs37-slb-ph2.slb.sfdc.net": "13.110.52.112",
              "org-cce2e-cs40-slb-ph2.slb.sfdc.net": "13.110.52.113",
              "org-cce2e-cs41-slb-ph2.slb.sfdc.net": "13.110.52.114",
              "org-cce2e-cs42-slb-ph2.slb.sfdc.net": "13.110.52.115",
              "org-cce2e-cs43-slb-ph2.slb.sfdc.net": "13.110.52.116",
              "org-cce2e-cs44-slb-ph2.slb.sfdc.net": "13.110.52.117",
              "org-cce2e-cs45-slb-ph2.slb.sfdc.net": "13.110.52.118",
              "org-cce2e-cs46-slb-ph2.slb.sfdc.net": "13.110.52.119",
              "org-cce2e-cs49-slb-ph2.slb.sfdc.net": "13.110.52.120",
            },
            "phx-sam": {
              "slb-canary-proxy-http-ext.sam-system.phx-sam.phx.slb.sfdc.net": "13.110.30.5",
              "gs0-bofa-phx.slb.sfdc.net": "13.110.30.11",
              "login-cloudforce-phx.slb.sfdc.net": "13.110.30.12",
              "sledge-phx.slb.sfdc.net": "13.110.30.13",
              "org-cce2e-cs3-slb-phx.slb.sfdc.net": "13.110.30.101",
              "org-cce2e-cs7-slb-phx.slb.sfdc.net": "13.110.30.102",
              "org-cce2e-cs9-slb-phx.slb.sfdc.net": "13.110.30.103",
              "org-cce2e-cs10-slb-phx.slb.sfdc.net": "13.110.30.104",
              "org-cce2e-cs11-slb-phx.slb.sfdc.net": "13.110.30.105",
              "org-cce2e-cs12-slb-phx.slb.sfdc.net": "13.110.30.106",
              "org-cce2e-cs13-slb-phx.slb.sfdc.net": "13.110.30.107",
              "org-cce2e-cs19-slb-phx.slb.sfdc.net": "13.110.30.108",
              "org-cce2e-cs20-slb-phx.slb.sfdc.net": "13.110.30.109",
              "org-cce2e-cs21-slb-phx.slb.sfdc.net": "13.110.30.110",
              "org-cce2e-cs23-slb-phx.slb.sfdc.net": "13.110.30.111",
              "org-cce2e-cs25-slb-phx.slb.sfdc.net": "13.110.30.112",
              "org-cce2e-cs26-slb-phx.slb.sfdc.net": "13.110.30.113",
              "org-cce2e-cs30-slb-phx.slb.sfdc.net": "13.110.30.114",
              "org-cce2e-cs50-slb-phx.slb.sfdc.net": "13.110.30.115",
              "org-cce2e-cs51-slb-phx.slb.sfdc.net": "13.110.30.116",
              "org-cce2e-cs52-slb-phx.slb.sfdc.net": "13.110.30.117",
              "org-cce2e-cs53-slb-phx.slb.sfdc.net": "13.110.30.118",
              "org-cce2e-cs54-slb-phx.slb.sfdc.net": "13.110.30.119",
              "org-cce2e-cs59-slb-phx.slb.sfdc.net": "13.110.30.120",
              "org-cce2e-cs60-slb-phx.slb.sfdc.net": "13.110.30.121",
              "org-cce2e-cs61-slb-phx.slb.sfdc.net": "13.110.30.122",
              "org-cce2e-cs62-slb-phx.slb.sfdc.net": "13.110.30.123",
              "org-cce2e-cs63-slb-phx.slb.sfdc.net": "13.110.30.124",
              "org-cce2e-cs68-slb-phx.slb.sfdc.net": "13.110.30.125",
              "org-cce2e-cs69-slb-phx.slb.sfdc.net": "13.110.30.126",
              "org-cce2e-cs70-slb-phx.slb.sfdc.net": "13.110.30.127",
              "org-cce2e-cs71-slb-phx.slb.sfdc.net": "13.110.30.128",
              "org-cce2e-cs90-slb-phx.slb.sfdc.net": "13.110.30.129",
              "org-cce2e-cs91-slb-phx.slb.sfdc.net": "13.110.30.130",
              "org-cce2e-cs999-slb-phx.slb.sfdc.net": "13.110.30.131",
              "org-cce2e-na47-slb-phx.slb.sfdc.net": "13.110.30.132",
              "org-certtest-gs0-slb-phx.slb.sfdc.net": "13.110.30.133",
            },
            "prd-samtwo": {
              "na44-stmfa1-0-prd.slb.sfdc.net": "136.146.214.8",
              "na44-stmfb1-0-prd.slb.sfdc.net": "136.146.214.9",
              "na44-stmfc1-0-prd.slb.sfdc.net": "136.146.214.10",
              "slb-canary-proxy-http-ext.sam-system.prd-samtwo.prd.slb.sfdc.net": "136.146.214.5",
            },
            # C360 -- start -- W-6124538
            "iad-sam": {
              "rsui-production-iad-lb.retail-rsui.iad-sam.iad.slb.sfdc.net": "13.110.24.14",
              "rsui-production-iad-test-lb.retail-rsui.iad-sam.iad.slb.sfdc.net": "13.110.24.15",
              "slb-canary-proxy-http-ext.sam-system.iad-sam.iad.slb.sfdc.net": "13.110.24.5",
              "sledge-iad.slb.sfdc.net": "13.110.24.13",
              "org-cce2e-cs8-slb-iad.slb.sfdc.net": "13.110.24.101",
              "org-cce2e-cs14-slb-iad.slb.sfdc.net": "13.110.24.102",
              "org-cce2e-cs15-slb-iad.slb.sfdc.net": "13.110.24.103",
              "org-cce2e-cs16-slb-iad.slb.sfdc.net": "13.110.24.104",
              "org-cce2e-cs17-slb-iad.slb.sfdc.net": "13.110.24.105",
              "org-cce2e-cs18-slb-iad.slb.sfdc.net": "13.110.24.106",
              "org-cce2e-cs47-slb-iad.slb.sfdc.net": "13.110.24.107",
              "org-cce2e-cs64-slb-iad.slb.sfdc.net": "13.110.24.108",
              "org-cce2e-cs65-slb-iad.slb.sfdc.net": "13.110.24.109",
              "org-cce2e-cs66-slb-iad.slb.sfdc.net": "13.110.24.110",
              "org-cce2e-cs67-slb-iad.slb.sfdc.net": "13.110.24.111",
              "org-cce2e-cs77-slb-iad.slb.sfdc.net": "13.110.24.112",
              "org-cce2e-cs78-slb-iad.slb.sfdc.net": "13.110.24.113",
              "org-cce2e-cs79-slb-iad.slb.sfdc.net": "13.110.24.114",
              "org-cce2e-cs92-slb-iad.slb.sfdc.net": "13.110.24.115",
              "org-cce2e-cs93-slb-iad.slb.sfdc.net": "13.110.24.116",
              "org-cce2e-cs94-slb-iad.slb.sfdc.net": "13.110.24.117",
              "org-cce2e-cs95-slb-iad.slb.sfdc.net": "13.110.24.118",
              "org-cce2e-cs96-slb-iad.slb.sfdc.net": "13.110.24.119",
              "org-cce2e-cs97-slb-iad.slb.sfdc.net": "13.110.24.120",
            },
            "ord-sam": {
              "rsui-production-ord-lb.retail-rsui.ord-sam.ord.slb.sfdc.net": "13.110.26.14",
              "rsui-production-ord-test-lb.retail-rsui.ord-sam.ord.slb.sfdc.net": "13.110.26.15",
              "slb-canary-proxy-http-ext.sam-system.iad-sam.iad.slb.sfdc.net": "13.110.26.5",
              "sledge-iad.slb.sfdc.net": "13.110.26.13",
              "org-cce2e-cs8-slb-ord.slb.sfdc.net": "13.110.26.101",
              "org-cce2e-cs14-slb-ord.slb.sfdc.net": "13.110.26.102",
              "org-cce2e-cs15-slb-ord.slb.sfdc.net": "13.110.26.103",
              "org-cce2e-cs16-slb-ord.slb.sfdc.net": "13.110.26.104",
              "org-cce2e-cs17-slb-ord.slb.sfdc.net": "13.110.26.105",
              "org-cce2e-cs18-slb-ord.slb.sfdc.net": "13.110.26.106",
              "org-cce2e-cs47-slb-ord.slb.sfdc.net": "13.110.26.107",
              "org-cce2e-cs64-slb-ord.slb.sfdc.net": "13.110.26.108",
              "org-cce2e-cs65-slb-ord.slb.sfdc.net": "13.110.26.109",
              "org-cce2e-cs66-slb-ord.slb.sfdc.net": "13.110.26.110",
              "org-cce2e-cs67-slb-ord.slb.sfdc.net": "13.110.26.111",
              "org-cce2e-cs77-slb-ord.slb.sfdc.net": "13.110.26.112",
              "org-cce2e-cs78-slb-ord.slb.sfdc.net": "13.110.26.113",
              "org-cce2e-cs79-slb-ord.slb.sfdc.net": "13.110.26.114",
              "org-cce2e-cs92-slb-ord.slb.sfdc.net": "13.110.26.115",
              "org-cce2e-cs93-slb-ord.slb.sfdc.net": "13.110.26.116",
              "org-cce2e-cs94-slb-ord.slb.sfdc.net": "13.110.26.117",
              "org-cce2e-cs95-slb-ord.slb.sfdc.net": "13.110.26.118",
              "org-cce2e-cs96-slb-ord.slb.sfdc.net": "13.110.26.119",
              "org-cce2e-cs97-slb-ord.slb.sfdc.net": "13.110.26.120",
            },
            # C360 -- end
            "ukb-sam": {
              "rsui-production-ukb-lb.retail-rsui.ukb-sam.ukb.slb.sfdc.net": "161.71.146.14",
              "rsui-production-ukb-test-lb.retail-rsui.ukb-sam.ukb.slb.sfdc.net": "161.71.146.15",
              "sledge-ukb.slb.sfdc.net": "161.71.146.13",
            },
            "hnd-sam": {
              "rsui-production-hnd-lb.retail-rsui.hnd-sam.hnd.slb.sfdc.net": "161.71.144.14",
              "rsui-production-hnd-test-lb.retail-rsui.hnd-sam.hnd.slb.sfdc.net": "161.71.144.15",
              "slb-canary-proxy-http-ext.sam-system.hnd-sam.hnd.slb.sfdc.net": "161.71.144.5",
              "sledge-hnd.slb.sfdc.net": "161.71.144.13",
            },
            "ia2-sam": {
              "org-cce2e-cs1-slb-ia2.slb.sfdc.net": "13.110.50.101",
              "org-cce2e-cs2-slb-ia2.slb.sfdc.net": "13.110.50.102",
              "org-cce2e-cs4-slb-ia2.slb.sfdc.net": "13.110.50.103",
              "org-cce2e-cs22-slb-ia2.slb.sfdc.net": "13.110.50.104",
              "org-cce2e-cs24-slb-ia2.slb.sfdc.net": "13.110.50.105",
              "org-cce2e-cs27-slb-ia2.slb.sfdc.net": "13.110.50.106",
              "org-cce2e-cs28-slb-ia2.slb.sfdc.net": "13.110.50.107",
              "org-cce2e-cs29-slb-ia2.slb.sfdc.net": "13.110.50.108",
              "org-cce2e-cs34-slb-ia2.slb.sfdc.net": "13.110.50.109",
              "org-cce2e-cs35-slb-ia2.slb.sfdc.net": "13.110.50.110",
              "org-cce2e-cs36-slb-ia2.slb.sfdc.net": "13.110.50.111",
              "org-cce2e-cs37-slb-ia2.slb.sfdc.net": "13.110.50.112",
              "org-cce2e-cs40-slb-ia2.slb.sfdc.net": "13.110.50.113",
              "org-cce2e-cs41-slb-ia2.slb.sfdc.net": "13.110.50.114",
              "org-cce2e-cs42-slb-ia2.slb.sfdc.net": "13.110.50.115",
              "org-cce2e-cs43-slb-ia2.slb.sfdc.net": "13.110.50.116",
              "org-cce2e-cs44-slb-ia2.slb.sfdc.net": "13.110.50.117",
              "org-cce2e-cs45-slb-ia2.slb.sfdc.net": "13.110.50.118",
              "org-cce2e-cs46-slb-ia2.slb.sfdc.net": "13.110.50.119",
              "org-cce2e-cs49-slb-ia2.slb.sfdc.net": "13.110.50.120",
            },
        },

        privateReservedIps:
            set_value_to_all_in_list({}, $.testEstates)
            + set_value_to_all_in_list({}, $.prodEstates)
            + {
                "dfw-sam": {
                  "sec0-magister1-0-dfw.slb.sfdc.net": "10.214.188.141",
                },
                "frf-sam": {
                  "kubernetes-api-flowsnake-frf.slb.sfdc.net": "10.214.36.129",
                  "cre-control-plane-lb.retail-cre.frf-sam.frf.slb.sfdc.net": "10.214.36.14",
                  "cre-sp-lb.retail-cre.frf-sam.frf.slb.sfdc.net": "10.214.36.140",
                  "cre-api-lb.retail-cre.par-sam.frf.slb.sfdc.net": "10.214.36.144",
                  "metadata-service-lb.retail-mds.frf-sam.frf.slb.sfdc.net": "10.214.36.146",
                  "dfs-production-lb.retail-dfs.frf-sam.frf.slb.sfdc.net": "10.214.36.141",
                  "rsui-service-frf-lb.retail-rsui.frf-sam.frf.slb.sfdc.net": "10.214.36.145",
                  "hub-persistence-lb.retail-rsui.frf-sam.frf.slb.sfdc.net": "10.214.36.147",
                },
                "par-sam": {
                  "kubernetes-api-flowsnake-par.slb.sfdc.net": "10.214.112.129",
                  "cre-control-plane-lb.retail-cre.par-sam.par.slb.sfdc.net": "10.214.112.103",
                  "cre-sp-lb.retail-cre.par-sam.par.slb.sfdc.net": "10.214.112.107",
                  "cre-api-lb.retail-cre.par-sam.par.slb.sfdc.net": "10.214.112.124",
                  "metadata-service-lb.retail-mds.par-sam.par.slb.sfdc.net": "10.214.112.131",
                  "dfs-production-lb.retail-dfs.par-sam.par.slb.sfdc.net": "10.214.112.132",
                  "rsui-service-par-lb.retail-rsui.par-sam.par.slb.sfdc.net": "10.214.112.135",
                  "hub-persistence-lb.retail-rsui.par-sam.par.slb.sfdc.net": "10.214.112.14",
                },
                "phx-sam": {
                  "sec0-magister1-0-phx.slb.sfdc.net.": "10.208.208.144",
                },
                "prd-sam": {
                  "rsui-func-lb.retail-rsui.prd-sam.prd.slb.sfdc.net": "10.251.196.42",
                  "rsui-perf-lb.retail-rsui.prd-sam.prd.slb.sfdc.net": "10.251.196.44",
                  "ops0-dvaregistryssl1-0-prd.slb.sfdc.net": "10.251.197.44",
                  "gatekeeper-dashboardlb.gatekeeper.prd-sam.prd.slb.sfdc.net": "10.251.196.212",  #  - Peijun Wu - https://computecloud.slack.com/archives/C42SAQVS9/p1556063807120000?thread_ts=1556038442.093300&cid=C42SAQVS9
                  "ops0-netlog1-0-prd.slb.sfdc.net": "10.251.196.113",  #  - Zack Mady - https://computecloud.slack.com/archives/C42SAQVS9/p1556121900123900
                  "codecov.moe.prd-sam.prd.slb.sfdc.net": "10.251.196.117",
                },
                # C360 -- start -- W-6124538
                "iad-sam": {
                  "cre-api-lb.retail-cre.iad-sam.iad.slb.sfdc.net": "10.208.108.100",
                  "cre-control-plane-lb.retail-cre.iad-sam.iad.slb.sfdc.net": "10.208.108.10",
                  "cre-sp-lb.retail-cre.iad-sam.iad.slb.sfdc.net": "10.208.108.107",
                  "dfs-production-lb.retail-dfs.iad-sam.iad.slb.sfdc.net": "10.208.108.148",
                  "metadata-service-lb.retail-mds.iad-sam.iad.slb.sfdc.net": "10.208.108.14",
                  "rsui-service-iad-lb.retail-rsui.iad-sam.iad.slb.sfdc.net": "10.208.108.15",
                  "hub-persistence-lb.retail-rsui.iad-sam.iad.slb.sfdc.net": "10.208.108.152",
                },
                "ord-sam": {
                  "cre-api-lb.retail-cre.ord-sam.ord.slb.sfdc.net": "10.208.148.0",
                  "cre-control-plane-lb.retail-cre.ord-sam.ord.slb.sfdc.net": "10.208.148.11",
                  "cre-sp-lb.retail-cre.ord-sam.ord.slb.sfdc.net": "10.208.148.110",
                  "dfs-production-lb.retail-dfs.ord-sam.ord.slb.sfdc.net": "10.208.148.148",
                  "metadata-service-lb.retail-mds.ord-sam.ord.slb.sfdc.net": "10.208.148.147",
                  "rsui-service-ord-lb.retail-rsui.ord-sam.ord.slb.sfdc.net": "10.208.148.109",
                  "hub-persistence-lb.retail-rsui.ord-sam.ord.slb.sfdc.net": "10.208.148.116",
                },
                # C360 -- end
                "ukb-sam": {
                  "cre-control-plane-lb.retail-cre.ukb-sam.ukb.slb.sfdc.net": "10.213.36.109",
                  "cre-sp-lb.retail-cre.ukb-sam.ukb.slb.sfdc.net": "10.213.36.117",
                  "cre-api-lb.retail-cre.par-sam.ukb.slb.sfdc.net": "10.213.36.125",
                  "metadata-service-lb.retail-mds.ukb-sam.ukb.slb.sfdc.net": "10.213.36.126",
                  "dfs-production-lb.retail-dfs.ukb-sam.ukb.slb.sfdc.net": "10.213.36.121",
                  "rsui-service-ukb-lb.retail-rsui.ukb-sam.ukb.slb.sfdc.net": "10.213.36.122",
                  "hub-persistence-lb.retail-rsui.ukb-sam.ukb.slb.sfdc.net": "10.213.36.127",
                },
                "hnd-sam": {
                  "cre-control-plane-lb.retail-cre.hnd-sam.hnd.slb.sfdc.net": "10.213.100.136",
                  "cre-sp-lb.retail-cre.hnd-sam.hnd.slb.sfdc.net": "10.213.100.137",
                  "cre-api-lb.retail-cre.par-sam.hnd.slb.sfdc.net": "10.213.100.14",
                  "metadata-service-lb.retail-mds.hnd-sam.hnd.slb.sfdc.net": "10.213.100.140",
                  "dfs-production-lb.retail-dfs.hnd-sam.hnd.slb.sfdc.net": "10.213.100.138",
                  "rsui-service-hnd-lb.retail-rsui.hnd-sam.hnd.slb.sfdc.net": "10.213.100.139",
                  "hub-persistence-lb.retail-rsui.hnd-sam.hnd.slb.sfdc.net": "10.213.100.141",
                },
                "xrd-sam": {
                  "ssh-to-somewhere-slb-xrd.slb.sfdc.net": "10.229.32.129",
                  "check-slb-xrd.slb.sfdc.net": "10.229.32.128",
                },
            },
}
