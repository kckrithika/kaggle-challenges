local configs = import "config.jsonnet";
if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "prometheus-rm-svc",
        namespace: "sam-system",
        labels: {
            app: "prometheus-rm",
        } + configs.ownerLabel.sam,
        annotations: if configs.estate == "prd-sam" then {
            "slb.sfdc.net/name": "prometheus-rm",
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
        } else {},
    },

    spec: {
              ports: [
                  {
                      name: "prometheus-rm-port",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9090,
                  },
              ],
              selector: {
                  name: "prometheus-rm",
              },
          }
          # We dont have SLB on test beds, so add in a node port
          + if configs.estate != "prd-sam" then {
              ports: [super.ports[0] { nodePort: 38001 }],
              type: "NodePort",
          } else {},
} else "SKIP"
