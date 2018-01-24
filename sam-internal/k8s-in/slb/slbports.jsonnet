{
    # This helps to avoid same port usage by services with other services running in the same cluster.

    # Here is the syntax to the format to be used:
    # "<teamname>": {
    #     serviceA: portA,
    #     serviceB: portB
    # },

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

        slbNginxProxyLivenessProbePort: 12080,
        slbConfigProcessorLivenessProbePort: 9876,
        slbBaboonLivenessProbePort: 9877,

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
        baboonEndPointPort: 32150,
    },
}
