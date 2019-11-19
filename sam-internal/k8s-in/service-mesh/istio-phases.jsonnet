local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local configs = import "config.jsonnet";
local namespaces = (import "namespaces/mesh-namespaces.jsonnet") + { templateFilename:: std.thisFile };

{
  phase: (
    if (estate == "prd-samtest") then "1"
    else if (estate == "prd-sam") then "2"
    else if (estate == "par-sam") then "3"
    else if (estate == "phx-sam") then "4"
    else "5"  # Deploy to all DCs
  ),

  phaseNum: std.parseInt($.phase),

  funnelEndpoint: (
      "ajnafunneldirecttls.funnel.svc.mesh.sfdc.net:7442"
  ),

  sidecarEgressHosts: (
  if ($.phaseNum < 3) then
    // System namespaces
    ["mesh-control-plane/*", "z9s-default/*"] +
    // App namespaces
    [("%s/*" % ns) for ns in namespaces.istioEnabledNamespaces("prd")]
    else
    [
      // System namespaces
      "mesh-control-plane/*",
      "z9s-default/*",

      // App namespaces
      "app/*",
      "casam/*",
      "ccait/*",
      "core-on-sam-sp2/*",
      "emailinfra/*",
      "funnel/*",
      "gater/*",
      //"retail-cre/*",
      //"retail-dfs/*",
      //"retail-mds/*",
      //"retail-rsui/*",
      "scone/*",
      "search-scale-safely/*",
      "service-mesh/*",
      "universal-search/*",
    ]
  ),
}
