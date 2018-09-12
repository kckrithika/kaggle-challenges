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
    enableDNS: if samfeatureflags.kubedns then true,
    dnsEnabledPoolNamesRegex: (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then ".*"),

  #k4a
  [if configs.estate == "vpod" then "enableK4a"]: false,

  # others
    volPermissionInitContainerImage: samimages.permissionInitContainer,
    dockerRegistry: (if configs.estate == "prd-samdev" then "ops0-artifactrepo1-0-prd.data.sfdc.net" else configs.registry),

  namespaceHostSubList: (
     if util.is_production(configs.kingdom) then ["cloudatlas"]
     else [".*"]
   ),
   ipAddressCapacityRequest: (if samfeatureflags.ipAddressCapacityRequest then true),


  #enableIdentityEnvVar
  enableIdentityEnvVar: (if samfeatureflags.enableIdentityEnvVar then true else false),
})
