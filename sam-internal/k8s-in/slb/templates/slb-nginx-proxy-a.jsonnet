local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local samimages = import "sam/samimages.jsonnet";

if configs.estate == "prd-sam" then {
  apiVersion: "extensions/v1beta1",
      kind: "Deployment",
      metadata: {
          labels: {
              name: "slb-nginx-proxy-a",
          },
          name: "slb-nginx-proxy-a",
          namespace: "sam-system",
      },
      spec: {
          replicas: 1,
          template: {
              metadata: {
                  labels: {
                      name: "slb-nginx-proxy-a",
                  },
                  namespace: "sam-system",
              },
              spec: {
                  hostNetwork: true,
                  volumes: configs.filter_empty([
                       {
                          name: "var-target-config-volume",
                          hostPath: {
                              path: slbconfigs.slbDockerDir + "/nginx/config",
                           },
                       },
                       slbconfigs.logs_volume,
                       configs.sfdchosts_volume,
                  ]),
                  containers: [
                      {
                          name: "slb-nginx-proxy-a",
                          image: slbimages.slbnginx,
                          command: ["/runner.sh"],
                          livenessProbe: {
                          httpGet: {
                              path: "/",
                              port: portconfigs.slb.slbNginxProxyLivenessProbePort,
                          },
                          initialDelaySeconds: 15,
                          periodSeconds: 10,
                          },
                          volumeMounts: configs.filter_empty([
                          {
                              name: "var-target-config-volume",
                              mountPath: "/etc/nginx/conf.d",
                          },
                          slbconfigs.logs_volume_mount,
                          ]),
                      },
                  {
                      name: "slb-file-watcher",
                      image: slbimages.hypersdn,
                      command: [
                          "/sdn/slb-file-watcher",
                          "--filePath=/host/data/slb/logs/slb-nginx-proxy.emerg.log",
                          "--metricName=nginx-emergency",
                          "--lastModReportTime=120s",
                          "--scanPeriod=10s",
                          "--skipZeroLengthFiles=true",
                          "--metricsEndpoint=" + configs.funnelVIP,
                          "--log_dir=" + slbconfigs.logsDir,
                          configs.sfdchosts_arg,
                      ],
                  volumeMounts: configs.filter_empty([
                      {
                          name: "var-target-config-volume",
                          mountPath: "/etc/nginx/conf.d",
                      },
                      slbconfigs.logs_volume_mount,
                      configs.sfdchosts_volume_mount,
                  ]),
                  },
                  ],

                  nodeSelector: {
                      "slb-service": "slb-nginx-a",
                  },
              },
          },
      },
} else "SKIP"
