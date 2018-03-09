local configs = import "config.jsonnet";
if configs.kingdom == "prd" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "samcontrol-deployer",
        namespace: "sam-system",
        labels: {
            app: "samcontrol-deployer",
        },
        annotations: {
            "slb.sfdc.net/name": "samcontrol-deployer",
            "slb.sfdc.net/portconfigurations": std.toString(
                [
                    {
                        port: 80,
                        targetport: $.spec.ports[0].targetPort,
                        nodeport: 0,
                        lbtype: "",
                        reencrypt: false,
                        sticky: 0,
                    },
                ]
            ),
        },
    },
    spec: {
              ports: [
                  {
                      name: "deployer-portal-port",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9099,
                  },
              ],
              selector: {
                  name: "samcontrol-deployer",
              },
          }
          # The 2 test beds dont have SLB, so we need to add nodePorts
          # This is a little ugly, but here is what is going on.  In jsonnet
          # ObjA + ObjB is not a simle merge, it is more like ObjA is the base class
          # and ObjB is derived.  Here we add a second spec object, but the field
          # ports is computed from the base ports but with a tweak.
          + if (configs.estate != "prd-sam") then {
              ports: [super.ports[0] { nodePort: 32864 }],
              type: "NodePort",
          } else {},
} else "SKIP"
