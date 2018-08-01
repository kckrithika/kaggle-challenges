local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";

std.prune({
  # MadDog
    enableMaddog: samfeatureflags.maddogforsamapps,
    maddogMaddogEndpoint: if configs.estate == "vpod" then "https://maddog-onebox:8443" else configs.maddogEndpoint,
    madkubImage: samimages.madkubSidecar,
    enableMaddogCopyTestCA: samfeatureflags.maddogCopyTestCA,

  #k4a
  [if configs.estate == "vpod" then "enableK4a"]: "false",
  # others
    volPermissionInitContainerImage: samimages.permissionInitContainer,
    dockerRegistry: configs.registry,
})
