###
#
# Do not forget to RUN ./generate-namespaces.sh if changing this file
#
###

## istio-inject: enabled enables both the webhooks - istio-sidecar-injector & istio-routing-webhook
local utils = import "util_functions.jsonnet";
local configs = import "config.jsonnet";
local mesh_namespaces = ["app", "service-mesh", "funnel", "gater", "ccait", "core-on-sam-sp2", "core-on-sam", "casam", "emailinfra", "universal-search", "search-scale-safely", "retail-cre", "retail-dfs", "retail-dss", "cloudatlas", "retail-eventlistener", "retail-mds", "retail-rrps", "retail-rsui", "retail-setup", "scone"];

local istioSvcNamespaces = {
  prd: mesh_namespaces,
  mvp: mesh_namespaces,
  par: ["app", "funnel", "service-mesh"],
};


{
  // Returns a list of all possible NS variations to iterate over and create individual files for each NS
  allNs: mesh_namespaces,

  // Determines if an NS in an individual file should be deployed to a Kingdom
  // TODO: for now we use this for samtest and samdev only
  shouldDeployToKingdom(namespaceName, kingdom):: 
  ((configs.estate == "prd-samdev" || configs.estate == "prd-samtest")
    && (std.count(istioSvcNamespaces[kingdom], namespaceName) > 0)),
  
  newMeshNamespace(NamespaceName):: {
    apiVersion: "v1",
    kind: "Namespace",
    metadata: {
      labels: {
        "istio-injection": "enabled",
      } + (if NamespaceName == "service-mesh" && (configs.kingdom == "prd" || configs.kingdom == "mvp") then
        { "sherpa-injection": "enabled" } else {}) +
        (if NamespaceName == "service-mesh" && configs.kingdom == "prd" then
        { "electron-opa-injection": "enabled" } else {})
      +
      // samlabelfilter.json requires this label to be present on GCP deployments
      if utils.is_pcn(configs.kingdom) && NamespaceName == "service-mesh" then configs.pcnEnableLabel else {},
      name: NamespaceName,
    },
  },
}
