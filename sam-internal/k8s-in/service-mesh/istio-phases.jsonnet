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

  // TODO: Drop the extra conditional for phase 2 once we start rolling the increased replica counts out to production.

  # 1 Pilot instance in prd-samtest
  pilotReplicasCount: if ($.phaseNum == 1) then 1 else if ($.phaseNum == 2) then 5 else 3,
  # 1 sidecar-injector in prd-samtest
  sidecarInjectorWebhookReplicasCount: if ($.phaseNum == 1) then 1 else if ($.phaseNum == 2) then 5 else 3,
  # 1 routing webhook in prd-samtest
  routingWebhookReplicasCount: if ($.phaseNum == 1) then 1 else if ($.phaseNum == 2) then 5 else 3,
  # 1 route update service in prd-samtest
  routeUpdateServiceReplicasCount: if ($.phaseNum == 1) then 1 else if ($.phaseNum == 2) then 5 else 1,
  # 1 webhook failurePolicy
  webhookFailurePolicy: if ($.phaseNum > 2) then "Ignore" else "Fail",
}
