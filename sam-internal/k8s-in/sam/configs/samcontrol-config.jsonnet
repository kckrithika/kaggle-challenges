local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

# Please check this config before merge using:
#
# ~/go/bin/manifestctl validate-config-maps --in ~/manifests/sam-internal/k8s-out/
#
# This will be automated soon

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
  checkImageExistsFlag: (if configs.estate == "prd-samdev" then true else false),
}
+ (if (configs.estate == "prd-samdev") then {
  imageCheckV2: true,
} else {})
+ (if (configs.kingdom == "prd") then {
  deletionEnabled: true,
  deletionPercentageThreshold: 10,
  statefulAppEnabled: true,
  checkImageExistsFlag: true,
} else {})
+ (if configs.estate == "prd-samdev" || configs.estate == "prd-samtest" || configs.estate == "prd-sam" then {
    enableMaddog: true,
    # This is kept as a flag to use the service envvar,
    #maddogMadkubEndpoint: "https://10.254.208.254:32007",
    maddogMaddogEndpoint: "https://all.pkicontroller.pki.blank." + configs.kingdom + ".prod.non-estates.sfdcsd.net:8443",
    maddogMadkubImage: samimages.madkubSidecar,
    maddogMadkubImageRegistry: configs.registry + "/docker-release-candidate/tnrp",
  } else {})
