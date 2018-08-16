{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },

    local nodeApiUnixSocketEnabled = (if slbimages.hypersdn_build >= 1028 then true else false),
    local manifestWatcherEnabled = (if slbimages.phaseNum <= 1 then true else false),

    getNodeApiClientSocketSettings(configDir):: (if nodeApiUnixSocketEnabled then [
                                                     "--client.socketDir=" + configDir,
                                                     "--client.dialSocket=true",
                                                 ] else []),

    getNodeApiServerSocketSettings():: (if nodeApiUnixSocketEnabled then [
                                            "--listenOnSocket=true",
                                            "--readOnly=false",
                                        ] else []),

    getManifestWatcherIfEnabled():: (if manifestWatcherEnabled then [
                                            slbshared.slbManifestWatcher(),
                                     ] else []),
}
