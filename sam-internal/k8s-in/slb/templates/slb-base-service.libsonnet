local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local utils = import "util_functions.jsonnet";

{
  slbCanaryBaseService(canaryName, portConfigurations, serviceName=canaryName, vipName=canaryName, cnames=[]):: (
    # XRD is currently bumping into peering prefix limits (60) that restrict the number of distinct VIPs
    # we can serve before everything blows up. Disable canary VIPs in XRD until we can advertise more VIPs.
    # See https://computecloud.slack.com/archives/G340CE86R/p1551987919271500.
    local slbAnnotations = if configs.kingdom != "xrd" || serviceName == "slb-portal-service" then {
        annotations: {
          "slb.sfdc.net/name": vipName,
          "slb.sfdc.net/portconfigurations": slbportconfiguration.portConfigurationToString(portConfigurations),
        } + utils.fieldIfNonEmpty("slb.sfdc.net/cnames", cnames, std.manifestJsonEx(cnames, " ")),
    } else {};

    // Confirm the format of the cnames field -- it should be an array of objects containing cname: string pairs.
    if std.assertEqual("array", std.type(cnames)) &&
       std.length(cnames) == 0 || (
        std.assertEqual("object", std.type(cnames[0])) &&
        std.assertEqual(true, std.objectHas(cnames[0], "cname"))
      )
    then
    {
      apiVersion: "v1",
      kind: "Service",
      metadata: {
        name: serviceName,
        namespace: "sam-system",
        labels: {
          app: serviceName,
        } + configs.ownerLabel.slb,
      } + slbAnnotations,

      spec: {
        ports: [
          {
            name: c.name,
            port: c.port,
            protocol: "TCP",
            targetPort: c.targetport,
            [if c.nodeport != 0 then "nodePort"]: c.nodeport,
          }
for c in portConfigurations
        ],
        selector: {
          name: canaryName,
        },
        type: "NodePort",
      },
    }
  ),
}
