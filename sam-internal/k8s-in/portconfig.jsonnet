{
    # This helps to avoid same port usage by services with other services running in the same cluster.
    # Lists out port usages for each service (e.g. sam, sdn, slb etc...)

    # Here is the syntax to the format to be used:
    # "<teamname>": {
    #     serviceA: portA,
    #     serviceB: portB
    # },

    sam: {
        sam_secret_agent: "9098",
    },

    sdn: {
        sdn_peering_agent: 9100,
        sdn_ping_watchdog: 9102,
        sdn_route_watchdog: 9104,
        sdn_vault_agent: 9106,
        sdn_control_service: 9108,
        sdn_control: 9110,
        sdn_secret_agent: 9120,
        sdn_sdnc_watchdog: 9121,
        sdn_aws_controller: 9122,
    },
    slb: {
        ipvsDataConnPort: 9107,
        canaryServicePort: 9111,
        canaryServiceTlsPort: 9443,
        slbPortalServicePort: 9112,
        canaryServicePassthroughHostNetworkPort: 9113,
        canaryServicePassthroughTlsPort: 9114,
        canaryServiceProxyTcpPort: 9115,
        canaryServiceProxyHttpPort: 9116,
        slbConfigDataPort: 9117,
        slbEchoServicePort: 9118,
        canaryServiceHealthPort: 9119,

        slbNginxProxyLivenessProbePort: 12080,

        canaryServiceTlsNodePort: 32135,
        canaryServiceNodePort: 32136,
        alphaServiceNodePort: 32137,
        bravoServiceNodePort: 32138,
        slbPortalServiceNodePort: 32139,
        bravoServiceNodePort1: 32140,
        bravoServiceNodePort2: 32141,
        canaryServicePassthroughHostNetworkNodePort: 32142,
        canaryServicePassthroughTlsNodePort: 32143,
        canaryServiceProxyTcpNodePort: 32144,
        canaryServiceProxyHttpNodePort: 32145,
        slbNginxControlPort: 32146,
        bravoServiceNodePort3: 32147,
        slbEchoServiceNodePort: 32148,
        slbIpvsControlPort: 32149,
    },
    flowsnake: {
        nginx_ingress_http: 32080,
        nginx_ingress_https: 32443,
    },
}
