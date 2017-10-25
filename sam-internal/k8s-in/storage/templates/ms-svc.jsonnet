local configs = import "config.jsonnet";

if configs.estate == "prd-sam_storage" then {
   apiVersion: "v1",
   kind: "Service",
   metadata: {
      name: "metric-streamer",
      labels: {
         app: "metric-streamer",
      },
   },
   spec: {
      clusterIP: "None",
      ports: [
         {
            name: "http-metrics",
            port: 8001,
            protocol: "TCP",
            targetPort: 8001,
         },
      ],
      selector: {
         app: "metric-streamer",
      },
   },
} else "SKIP"
