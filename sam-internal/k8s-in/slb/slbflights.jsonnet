local configs = import "config.jsonnet";

{
    dirSuffix:: "",
    local slbimages = import "slbimages.jsonnet",
    local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    # Special feature flag for portal so we can initially release manifest watcher in portal's pod only
    local kubeDnsEnabled = false,
    stockIpvsModules: (if slbimages.phaseNum > 7 then true else false),
    nginxPodFloat: (slbimages.phaseNum <= 2),
    proxyProtocolCanaryEnabled: (slbimages.hypersdn_build >= 1331),
    envoyProxyEnabled: (slbimages.phaseNum <= 1),
    roleEnabled: (slbimages.phaseNum <= 1),
    slbCleanupTerminatingPods: (slbimages.hypersdn_build >= 1335),
    ipvsProcessorProxySelection: (slbimages.hypersdn_build >= 1337),
    nginxSlbVolumeMount: (slbimages.slbnginx_build >= 50),
    proxyConfigMapEnabled: (slbimages.hypersdn_build >= 1334),
    hsmCanaryEnabled: ((configs.estate == "prd-sdc" || configs.estate == "xrd-sam") && slbimages.phaseNum <= 3),
    removeDeprecatedNginxParameters: (slbimages.hypersdn_build >= 1340),
    nginxBaseTemplateEnabled: (slbimages.phaseNum <= 2),
    removeCleanupDs: (slbimages.hypersdn_build >= 1344),
}
