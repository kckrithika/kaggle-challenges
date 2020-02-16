local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";
local slbflights = import "slbflights.jsonnet";
local slbports = import "slbports.jsonnet";

if slbflights.enableIpvsTrafficTest then {
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "slb-ipvs-traffic-test-service",
        namespace: "sam-system",
        labels: {
            app: "slb-ipvs-traffic-test-service",
        },
        annotations: {
            "slb.sfdc.net/portconfigurations": std.toString(
                [
                    {
                        healthPath: "/",
                        lbtype: "tcp",
                        port: 9107,
                        targetport: 9107,
                    },
                ]
            ),
        },
    },

    spec: {
              ports: [
                  {
                      name: "slb-ipvs-traffic-test-port",
                      nodePort: slbports.slb.slbIpvsTrafficTestPort,
                      port: 9107,
                      protocol: "TCP",
                      targetPort: 9107,
                  },
              ],
              selector: {
                  name: "slb-ipvs",
              },
              type: "NodePort",
          },
} else "SKIP"
