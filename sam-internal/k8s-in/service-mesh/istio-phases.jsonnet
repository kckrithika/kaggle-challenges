local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local configs = import "config.jsonnet";
local namespaces = (import "namespaces/mesh-namespaces.jsonnet") + { templateFilename:: std.thisFile };

{
  phase: (
    if (estate == "prd-samtest") then "1"
    else if (estate == "prd-sam") then "2"
    else if (estate == "par-sam" || estate == "lo3-sam") then "3"
    else if (estate == "phx-sam") then "4"
    else "5"  # Deploy to all DCs
  ),

  phaseNum: std.parseInt($.phase),

  funnelEndpoint: (
      "ajnafunneldirecttls.funnel.svc.mesh.sfdc.net:7442"
  ),

  // TODO: Drop this field entirely once host whitelisting has been dropped in all phases.
  sidecarEgressHosts: (
    // System namespaces
    ["mesh-control-plane/*", "z9s-default/*"] +
    // App namespaces
    [("%s/*" % ns) for ns in namespaces.istioEnabledNamespaces(kingdom)]
  ),

  # 1 Pilot instance in prd-samtest
  pilotReplicasCount: if ($.phaseNum == 1) then 1 else 3,
  # 1 sidecar-injector in prd-samtest
  sidecarInjectorWebhookReplicasCount: if ($.phaseNum == 1) then 1 else 3,
  # 1 routing webhook in prd-samtest
  routingWebhookReplicasCount: if ($.phaseNum == 1) then 1 else 3,
}
