local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";
local utils = import "util_functions.jsonnet";

{
  # MadDog
  enableMaddog: (if !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom) then true else false),
  maddogMaddogEndpoint: "https://all.pkicontroller.pki.blank." + configs.kingdom + ".prod.non-estates.sfdcsd.net:8443",
  maddogMadkubImage: samimages.madkubSidecar,
}
