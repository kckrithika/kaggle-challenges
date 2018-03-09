local configs = import "config.jsonnet";
if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "prometheus-svc",
        namespace: "sam-system",
        labels: {
            app: "prometheus",
        },
        annotations: {
            "slb.sfdc.net/name": "prometheus",
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
                      name: "prometheus-port",
                      port: 80,
                      protocol: "TCP",
                      targetPort: 9090,
                  },
              ],
              selector: {
                  name: "prometheus",
              },
          }
          # We dont have SLB on test beds, so add in a node port
          + if configs.estate != "prd-sam" then {
              ports: [super.ports[0] { nodePort: 38000 }],
              type: "NodePort",
          } else {},
} else "SKIP"
