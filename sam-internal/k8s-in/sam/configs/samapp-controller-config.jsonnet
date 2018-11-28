local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";
local util = import "util_functions.jsonnet";

std.prune({
  # MadDog
    enableMaddog: samfeatureflags.maddogforsamapps,
    maddogMaddogEndpoint: if configs.estate == "vpod" then "https://maddog-onebox:8443" else configs.maddogEndpoint,
    madkubImage: samimages.madkubSidecar,
    enableMaddogCopyTestCA: samfeatureflags.maddogCopyTestCA,
    funnelEndpoint: configs.funnelVIP,

  # DNS
    enableDNS: true,
    dnsEnabledPoolNamesRegex: (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then ".*" else if configs.estate == "ord-sam" then "^ord-sam_search$" else if configs.estate == "yhu-sam" then "^yhu-sam_search$"),

  #k4a
  [if configs.estate == "vpod" then "enableK4a"]: false,
  k4aInitContainerImage: samimages.k4aInitContainerImage,

  # others
    volPermissionInitContainerImage: samimages.permissionInitContainer,
    dockerRegistry: configs.registry,

  namespaceHostSubList: (
     if util.is_production(configs.kingdom) then ["cloudatlas"]
     else [".*"]
   ),
   ipAddressCapacityRequest: (if samfeatureflags.ipAddressCapacityRequest then true),


  #enableIdentityEnvVar
  enableIdentityEnvVar: (if samfeatureflags.enableIdentityEnvVar then true else false),
})
