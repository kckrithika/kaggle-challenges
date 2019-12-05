###
#
# Do not forget to RUN ./generate-namespaces.sh after changing this file
#
###
local utils = import "util_functions.jsonnet";
local configs = import "config.jsonnet";

// A full list of all known namespaces that run Mesh
local all_known_mesh_namespaces = [
    "app", 
    "casam", 
    "ccait", 
    "cloudatlas", 
    "core-on-sam-sp2", 
    "core-on-sam", 
    "emailinfra", 
    "funnel", 
    "gater", 
    "gateway",
    "retail-cre", 
    "retail-dfs", 
    "retail-dss", 
    "retail-eventlistener", 
    "retail-mds", 
    "retail-rrps", 
    "retail-rsui", 
    "retail-setup", 
    "scone",
    "search-scale-safely", 
    "service-mesh", 
    "universal-search", 
  ];

local ci_namespaces_prd_only = [
    "ci-gateway",
  ];

// Kingdoms and namespaces where `Sherpa Injection` is enabled
local sherpaInjectionEnabled = {
  prd: ["service-mesh", "ccait"],
  mvp: ["service-mesh", "ccait"],
  par: ["service-mesh"],
};

// Kingdoms and namespaces where `Electron OPA Injection` is enabled
local electronOpaInjectionEnabled = {
  prd: ["service-mesh"],
};

// Kingdoms and namespaces where `Istio Injection` is enabled
local istioInjectionEnabled = {
  prd: all_known_mesh_namespaces + ci_namespaces_prd_only,
  mvp: all_known_mesh_namespaces,
  par: ["app", "funnel", "service-mesh"],
  lo3: ["app", "funnel", "service-mesh", "ccait", "gater", "search-scale-safely", "universal-search", "gateway"],
};


{
  // Returns a list of all possible NS variations to iterate over and create individual files for each NS
  allNs: all_known_mesh_namespaces + ci_namespaces_prd_only,

  istioEnabledNamespaces(kingdom): istioInjectionEnabled[kingdom],

  // Determines if an NS in an individual file should be deployed to a Kingdom
  shouldDeployToKingdom(namespaceName, kingdom):: (
      ((std.objectHas(istioInjectionEnabled, kingdom)) && (std.count(istioInjectionEnabled[kingdom], namespaceName) > 0)) || 
      ((std.objectHas(electronOpaInjectionEnabled, kingdom)) && (std.count(electronOpaInjectionEnabled[kingdom], namespaceName) > 0)) || 
      ((std.objectHas(sherpaInjectionEnabled, kingdom)) && (std.count(sherpaInjectionEnabled[kingdom], namespaceName) > 0)) 
    ),
  
  newMeshNamespace(namespaceName, kingdom):: {
    apiVersion: "v1",
    kind: "Namespace",
    metadata: {
      labels: {} +
        (
          if (std.objectHas(istioInjectionEnabled, kingdom)) && (std.count(istioInjectionEnabled[kingdom], namespaceName) > 0) then
            { "istio-injection": "enabled" } 
          else {}
        ) +
        (
          if (std.objectHas(electronOpaInjectionEnabled, kingdom)) && (std.count(electronOpaInjectionEnabled[kingdom], namespaceName) > 0) then
            { "electron-opa-injection": "enabled" } 
          else {}
        ) +
        (
          if (std.objectHas(sherpaInjectionEnabled, kingdom)) && (std.count(sherpaInjectionEnabled[kingdom], namespaceName) > 0) then
            { "sherpa-injection": "enabled" } 
          else {}
        ) +
        // samlabelfilter.json requires this label to be present on GCP deployments
        if utils.is_pcn(configs.kingdom) && namespaceName == "service-mesh" then configs.pcnEnableLabel else {},
        name: namespaceName,
    },
  },
}
