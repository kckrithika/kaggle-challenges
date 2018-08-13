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

  # DNS
    enableDNS: if samfeatureflags.kubedns then true,
    dnsEnabledPoolNamesRegex: (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then ".*"),
    #enableDNS: (import "./samcontrol-config.jsonnet").enableDNS,
    #dnsEnabledPoolNamesRegex: (import "./samcontrol-config.jsonnet").dnsEnabledPoolNamesRegex,

  #k4a
  [if configs.estate == "vpod" then "enableK4a"]: "false",

  #override for CI API
  [if configs.estate == "prd-sam" then "dualRun"]: "false",
  # others
    volPermissionInitContainerImage: samimages.permissionInitContainer,
    dockerRegistry: configs.registry,

  namespaceHostSubList: (
     if util.is_production(configs.kingdom) then ["cloudatlas"]
     else [".*"]
   ),
})
