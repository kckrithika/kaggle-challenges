{
    local slbimages = import "slbimages.jsonnet",

    local nodeApiUnixSocketEnabled = (if slbimages.phaseNum <= 0 then true else false),

    getNodeApiClientSocketSettings(configDir):: (if nodeApiUnixSocketEnabled then [
                                                     "--client.socketDir=" + configDir,
                                                     "--client.dialSocket=true",
                                                 ] else []),

    getNodeApiServerSocketSettings():: (if nodeApiUnixSocketEnabled then [
                                            "--listenOnSocket=true",
                                            "--readOnly=false",
                                        ] else []),
}
