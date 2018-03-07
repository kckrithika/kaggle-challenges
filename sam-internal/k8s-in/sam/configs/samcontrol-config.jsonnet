local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

std.prune({
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
  slbConfigInLabels: (if configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtwo" then true else if configs.kingdom != "prd" then false),
  slbConfigInAnnotations: (if configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtwo" then true else if configs.kingdom != "prd" then false),

  k4aInitContainerImage: (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.kingdom == "frf" || configs.kingdom == "iad" || configs.kingdom == "ord" then samimages.k4aInitContainerImage),

  livenessProbePort: (if configs.estate == "prd-samtest" then "22545"),

  # [mayank] This flag enables dns resolution for pods deployed by samcontroller
  # Technically enabling this without kubedns running only causes some misc events in the pod describe, but
  # we will enable kubedns soon and then we can enable it for prod as well.
  enableDNS: (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then true),
})
