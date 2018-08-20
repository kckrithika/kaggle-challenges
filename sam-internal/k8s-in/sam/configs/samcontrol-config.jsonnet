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
  livenessProbePort: "22545",
  ipAddressCapacityRequest: (if samfeatureflags.ipAddressCapacityRequest then true),

  # Delete
  deletionPercentageThreshold: 20,
  deletionEnabled: true,

  # Stateful
  statefulAppEnabled: (if configs.kingdom == "prd" || configs.kingdom == "phx" then true else false),

  # Image check
  imageCheckV2: true,
  checkImageExistsFlag: true,

  # MadDog
  enableMaddog: samfeatureflags.maddogforsamapps,
  maddogMaddogEndpoint: configs.maddogEndpoint,
  maddogMadkubImage: samimages.madkubSidecar,
  enableMaddogCopyTestCA: samfeatureflags.maddogCopyTestCA,

  # SLB
  slbConfigInLabels: (if configs.kingdom != "prd" then false),
  slbConfigInAnnotations: (if configs.kingdom != "prd" then false),

  k4aInitContainerImage: samimages.k4aInitContainerImage,

  # [mayank] This flag enables dns resolution for pods deployed by samcontroller
  # Technically enabling this without kubedns running only causes some misc events in the pod describe, but
  # we will enable kubedns soon and then we can enable it for prod as well.
  enableDNS: if samfeatureflags.kubedns then true,
  dnsEnabledPoolNamesRegex: (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then ".*"),

  # SDP
  createCRD: (if configs.kingdom == "prd" then true),
  createTPR: false,
})

# Controller V1 ignore namespace list
+ (if configs.estate == "prd-samdev" || configs.estate == "prd-samtest" || configs.estate == "prd-sam" then {
      // Keep V1 blackListNamespaceRegexp and V2WhiteListNamespaceRegex in sync to avoid dual processing
      // e2e-.*-csc-sam$ to skip processing/deleting e2e namespace in V1
      blackListNamespaceRegexp: ["e2e-.*-csc-sam$"] + (import "./bundle-controller-config.jsonnet").whiteListNamespaceRegexp,
  } else {})
