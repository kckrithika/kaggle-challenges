local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";

{
  # MadDog
    enableMaddog: true,
    maddogMaddogEndpoint: if configs.estate == "vpod" then "https://maddog-onebox:8443" else configs.maddogEndpoint,
    madkubImage: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/madkub:1.0.0-0000071-5a6dcab2",
    enableMaddogCopyTestCA: true,

  #k4a
  [if configs.estate == "vpod" then "enableK4a"]: "false",


  # others
    volPermissionInitContainerImage: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/hypersam:sam-c07d4afb-673",
    dockerRegistry: "ops0-artifactrepo2-0-prd.data.sfdc.net",
}
