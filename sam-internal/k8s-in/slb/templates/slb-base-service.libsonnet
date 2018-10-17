local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";

{
  slbCanaryBaseService(canaryName, portConfigurations, serviceName=canaryName, vipName=canaryName, cnames=[])::
  {
    apiVersion: "v1",
    kind: "Service",
    metadata: {
      name: serviceName,
      namespace: "sam-system",
      labels: {
        app: serviceName,
        [if slbflights.useDeprecatedCanaryDifferences then "slb.sfdc.net/name"]: vipName,
      } + configs.ownerLabel.slb,
      annotations: {
        "slb.sfdc.net/name": vipName,
        "slb.sfdc.net/portconfigurations": slbportconfiguration.portConfigurationToString(portConfigurations),
      } + (if std.length(cnames) > 0 then {
        "slb.sfdc.net/cnames": std.manifestJsonEx(cnames, " ")
      } else {}) ,
    },

    spec: {
      ports: [
        {
          name: c.name,
          port: c.port,
          protocol: "TCP",
          targetPort: c.targetport,
          [if c.nodeport != 0 then "nodePort"]: c.nodeport,
        } for c in portConfigurations
      ],
      selector: {
        name: canaryName,
      },
      type: "NodePort",
    }
  },
}