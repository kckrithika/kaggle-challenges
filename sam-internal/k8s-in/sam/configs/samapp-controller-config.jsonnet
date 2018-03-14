local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samfeatureflags = import "sam-feature-flags.jsonnet";

{
  # MadDog
  enableMaddog: samfeatureflags.maddogforsamapps,
  maddogMaddogEndpoint: "https://all.pkicontroller.pki.blank." + configs.kingdom + ".prod.non-estates.sfdcsd.net:8443",
  maddogMadkubImage: samimages.madkubSidecar,
}
