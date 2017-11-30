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
  checkImageExistsFlag: (if configs.kingdom == "prd" then true else false),
  imageCheckV2: true,
}
+ (if (configs.kingdom == "prd") then {
  deletionEnabled: true,
  deletionPercentageThreshold: 10,
  statefulAppEnabled: true,
  checkImageExistsFlag: true,
} else {})
+ (if !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom) then {
    enableMaddog: true,
    # This is kept as a flag to use the service envvar,
    #maddogMadkubEndpoint: "https://10.254.208.254:32007",
    maddogMaddogEndpoint: "https://all.pkicontroller.pki.blank." + configs.kingdom + ".prod.non-estates.sfdcsd.net:8443",
    maddogMadkubImage: samimages.madkubSidecar,
  } else {})
  + (if samimages.per_phase[samimages.phase].hypersam == "sam-0001355-581a778b" && (!utils.is_public_cloud(configs.kingdom)) then {
    maddogMadkubImageRegistry: configs.registry + (if configs.kingdom == "prd" then "/docker-release-candidate/tnrp" else "/tnrp"),
  } else {})
+ (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    k4aInitContainerImage: samimages.k4aInitContainerImage,
  } else {})
+ (if configs.estate == "prd-samtest" then {
    livenessProbePort: "22545",
  } else {})
+ (if configs.kingdom == "prd" then {
    slbConfigInLabels: true,
  } else {})
+ (if configs.kingdom == "prd" then {
      slbConfigInAnnotations: true,
    } else {})
