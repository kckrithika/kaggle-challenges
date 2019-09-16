local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local configs = import "config.jsonnet";

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

}
