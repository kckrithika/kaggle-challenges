{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },

    local nodeApiUnixSocketEnabled = (if slbimages.hypersdn_build >= 1028 then true else false),
    # Special feature flag for portal so we can initially release manifest watcher in portal's pod only
    local portalManifestWatcherEnabled = (if slbimages.hypersdn_build >= 1057 then true else false),
    local manifestWatcherEnabled = (if slbimages.hypersdn_build >= 1061 then true else false),
    local kubeDnsEnabled = (if slbimages.phaseNum == 1 then false else true),

    getNodeApiClientSocketSettings(configDir):: (if nodeApiUnixSocketEnabled then [
                                                     "--client.socketDir=" + configDir,
                                                     "--client.dialSocket=true",
                                                 ] else []),

    getNodeApiServerSocketSettings():: (if nodeApiUnixSocketEnabled then [
                                            "--listenOnSocket=true",
                                            "--readOnly=false",
                                        ] else []),

    getPortalManifestWatcherIfEnabled():: (if portalManifestWatcherEnabled then [
                                            slbshared.slbManifestWatcher(),
                                        ] else []),
    getManifestWatcherIfEnabled():: (if manifestWatcherEnabled then [
                                            slbshared.slbManifestWatcher(),
                                     ] else []),

    getDnsPolicy():: (if kubeDnsEnabled then {} else { dnsPolicy: "Default" }),
}
