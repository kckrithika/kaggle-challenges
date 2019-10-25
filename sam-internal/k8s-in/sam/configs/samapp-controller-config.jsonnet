local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";
local utils = import "util_functions.jsonnet";

std.prune({
  # MadDog
    enableMaddog: samfeatureflags.maddogforsamapps,
    maddogMaddogEndpoint: if utils.is_pcn(configs.kingdom) then configs.maddogGCPEndpoint else (if configs.estate == "vpod" then "https://maddog-onebox:8443" else configs.maddogEndpoint),
    madkubImage: samimages.madkubSidecar,
    enableMaddogCopyTestCA: samfeatureflags.maddogCopyTestCA,
    funnelEndpoint: configs.funnelVIP,

  # DNS
    enableDNS: true,
    dnsEnabledPoolNamesRegex: ".*",

  #k4a
  [if configs.estate == "vpod" then "enableK4a"]: false,
  k4aInitContainerImage: samimages.k4aInitContainerImage,

  #pnc
  [if utils.is_pcn(configs.kingdom) then "slbUseIlbInGkeEnv"]: true,
  [if utils.is_pcn(configs.kingdom) then "dnsNamingSuffix"]: "vip.core.test.us-central1.gcp.sfdc.net.",

  #stateful
  enableStatefulSet: true,

  # others
    volPermissionInitContainerImage: samimages.permissionInitContainer,
    dockerRegistry: (if !utils.is_pcn(configs.kingdom) then configs.registry else ""),

  namespaceHostSubList: (
     if utils.is_production(configs.kingdom) then ["cloudatlas"]
     else [".*"]
   ),
   ipAddressCapacityRequest: (if samfeatureflags.ipAddressCapacityRequest then true),


  #enableIdentityEnvVar
  enableIdentityEnvVar: (if samfeatureflags.enableIdentityEnvVar then true else false),

  #imagePullPolicy
  imagePullPolicy: (if configs.kingdom == "prd" then "Always" else "IfNotPresent"),

  [if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then "enableIstioLabels"]: true,
})
