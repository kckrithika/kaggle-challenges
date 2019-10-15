local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then {
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    annotations: {
      "slb.sfdc.net/name": "sam-manifest-case-validator",
      "slb.sfdc.net/portconfigurations": std.toString(
          [
              {
                  port: 443,
                  targetport: $.spec.ports[0].targetPort,
                  lbtype: "tcp",
                  reencrypt: false,
                  sticky: 0,
              },
          ]
      ),
    },
    labels: {
      app: "sam-manifest-case-validator",
    } + configs.ownerLabel.sam,
    name: "sam-manifest-case-validator",
    namespace: "default",
  },
  spec: {
    ports: [
      {
        name: "sam-manifest-case-validator-port",
        port: 8443,
        protocol: "TCP",
        targetPort: 8443,
        nodePort: 39866,
      },
    ],
    selector: {
      name: "sam-manifest-case-validator",
    },
    type: "NodePort",
  },
} else "SKIP"
