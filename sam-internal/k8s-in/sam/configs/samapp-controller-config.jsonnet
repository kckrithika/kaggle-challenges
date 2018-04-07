local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";

{
  # MadDog
    enableMaddog: true,
    maddogMaddogEndpoint: "https://all.pkicontroller.pki.blank.prd.prod.non-estates.sfdcsd.net:8443",
    madkubImage: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/madkub:1.0.0-0000061-74e4a7b6",

  # others
    volPermissionInitContainerImage: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/hypersam:sam-c07d4afb-673",
    dockerRegistry: "ops0-artifactrepo2-0-prd.data.sfdc.net",
}
