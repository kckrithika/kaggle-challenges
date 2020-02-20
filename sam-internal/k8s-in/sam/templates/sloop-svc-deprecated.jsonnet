local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local legacyEstate = "prd-sam";

if samfeatureflags.sloop then {
  kind: "Service",
  apiVersion: "v1",
  metadata: {
    name: "sloop-legacy-" + legacyEstate,
    namespace: "sam-system",
    labels: {
      app: "sloop",
    } + configs.ownerLabel.sam,
    annotations: {
      "slb.sfdc.net/name": "sloop-" + legacyEstate,
      "slb.sfdc.net/portconfigurations": std.toString(
        [
          {
            port: 80,
            targetport: portconfigs.sloop.sloop,
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
        name: "sloop-port",
        port: 80,
        protocol: "TCP",
        targetPort: portconfigs.sloop.sloop,
      },
    ],
    selector: {
      app: "sloop-" + legacyEstate,
    },
  },
} else "SKIP"
