local configs = import "config.jsonnet";

if configs.estate == "prd-sam_storage" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
       name: "alerthandler",
       labels: {
          "k8s-app": "alerthandler",
       },
    },
    spec: {
       type: "NodePort",
       selector: {
          app: "alerthandler",
       },
       ports: [
          {
             name: "alert-hook",
             protocol: "TCP",
             port: 5001,
             nodePort: 35001,
             targetPort: 5001,
          },
          {
             name: "alert-publisher",
             protocol: "TCP",
             port: 5002,
             nodePort: 35002,
             targetPort: 5002,
          },
       ],
    },
} else "SKIP"
