local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

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
  enableMaddog: samfeatureflags.maddogforsamapps,
  maddogMaddogEndpoint: "https://all.pkicontroller.pki.blank." + configs.kingdom + ".prod.non-estates.sfdcsd.net:8443",
  maddogMadkubImage: samimages.madkubSidecar,

  # SLB
  slbConfigInLabels: (if configs.kingdom != "prd" then false),
  slbConfigInAnnotations: (if configs.kingdom != "prd" then false),

  k4aInitContainerImage: samimages.k4aInitContainerImage,

  livenessProbePort: (if configs.kingdom == "prd" || configs.kingdom == "frf" then "22545"),

  # [mayank] This flag enables dns resolution for pods deployed by samcontroller
  # Technically enabling this without kubedns running only causes some misc events in the pod describe, but
  # we will enable kubedns soon and then we can enable it for prod as well.
  enableDNS: (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then true),

  # SDP
  createCRD: (if configs.kingdom == "prd" then true),
  createTPR: false,
})

# Controller V1 ignore namespace list
+ (if configs.estate == "prd-samdev" || configs.estate == "prd-samtest" || configs.estate == "prd-sam" then {
      BlackListNamespaceRegexp: [
                 "e2e-.*-csc-sam$",
             ],
  } else {})
