local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";
local utils = import "util_functions.jsonnet";

{
  debug: true,
  dockerregistry: configs.registry,
  k8sapiserver: "",
  tlsEnabled: true,
  caFile: configs.caFile,
  keyFile: configs.keyFile,
  certFile: configs.certFile,
  httpsDisableCertsCheck: true,
  volPermissionInitContainerImage: samimages.permissionInitContainer,

  # Delete
  deletionPercentageThreshold: 20,
  deletionEnabled: (if configs.kingdom == "prd" then true else false),

  # Stateful
  statefulAppEnabled: (if configs.kingdom == "prd" || configs.kingdom == "phx" then true else false),

  # Image check
  imageCheckV2: true,
  checkImageExistsFlag: (if configs.kingdom == "prd" then true else false),

  # MadDog
  enableMaddog: (if !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom) then true else false),
  maddogMaddogEndpoint: "https://all.pkicontroller.pki.blank." + configs.kingdom + ".prod.non-estates.sfdcsd.net:8443",
  maddogMadkubImage: samimages.madkubSidecar,

  # SLB
  slbConfigInLabels: (if configs.kingdom == "prd" then true else false),
  slbConfigInAnnotations: (if configs.kingdom == "prd" then true else false),

}
+ (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.kingdom == "frf" then {
    k4aInitContainerImage: samimages.k4aInitContainerImage,
  } else {})
+ (if configs.estate == "prd-samtest" then {
    livenessProbePort: "22545",
  } else {})
+ (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    enableDNS: true,
  } else {})
