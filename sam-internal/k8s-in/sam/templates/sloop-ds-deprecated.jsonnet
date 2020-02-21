local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local sloop = import "configs/sloop-config.jsonnet";
local legacyEstate = "prd-sam";

if samfeatureflags.sloop then configs.daemonSetBase("sam") {
  spec+: {
    template: {
      spec: {
        serviceAccountName: "sloop",
        containers: [
          {
            name: "sloopds",
            resources: {
              requests: self.limits,
              limits: sloop.estateConfigs[legacyEstate].resource.limits,
            },
            args: [
              "--config=/sloopconfig/sloop.yaml",
              "--port=" + portconfigs.sloop.sloop,
              "--display-context=" + legacyEstate,
              "--apiserver-host=http://pseudo-kubeapi.csc-sam.prd-sam.prd.slb.sfdc.net:40001/" + legacyEstate + "/",
              # Default maximum history stored - 2 weeks
              "--max-look-back=336h",
            ] + sloop.estateConfigs[legacyEstate].resource.flags,
            command: [
              "/sloop",
            ],
            livenessProbe: {
              httpGet: {
                path: "/healthz",
                port: portconfigs.sloop.sloop,
              },
              # We have a 30 minute startup - badger has to load AND compact all data before sloop starts the web server.
              # If we have a lot of data on disk it can take a long time to start.
              # If liveness kills sloop before it finishes compacting then we go into an infinite death loop with complete downtime for users which is not ideal.
              initialDelaySeconds: 1800,
              timeoutSeconds: 5,
            },
            readinessProbe: {
              httpGet: {
                path: "/healthz",
                port: portconfigs.sloop.sloop,
              },
              timeoutSeconds: 5,
            },
            image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/sjawad/sloop:sjawad-20200220_160659-e77a2d5",
            volumeMounts: [
              {
                name: "sloop-data",
                mountPath: "/data/",
              },
              {
                name: "sloopconfig",
                mountPath: "/sloopconfig/",
              },
            ],
            ports: [
              {
                containerPort: portconfigs.sloop.sloop,
                protocol: "TCP",
              },
            ],
          },
          {
            name: "prometheus",
            args: [
              "--config.file",
              "/prometheusconfig/prometheus.json",
            ],
            image: samimages.prometheus,
            volumeMounts: [
              {
                name: "prom-data",
                # For some reason we are getting permission denied on the host-mount
                # Moving this mount will mean prometheus writes to local docker FS
                # TODO: Fix this properly
                mountPath: "/dummy-prometheus/data",
              },
              {
                name: "sloopconfig",
                mountPath: "/prometheusconfig",
              },
            ],
            ports: [
              {
                containerPort: 9090,
                protocol: "TCP",
              },
            ],
          },
        ],
        volumes+: [
          {
            hostPath: {
                path: "/data/sloop-data/" + legacyEstate,
            },
            name: "sloop-data",
          },
          {
            hostPath: {
                path: "/data/sloop-prom-data/" + legacyEstate,
            },
            name: "prom-data",
          },
          {
            configMap: {
                name: "sloop",
            },
            name: "sloopconfig",
          },
        ],
        nodeSelector:
          sloop.sloopNodeSelectors[configs.estate],
      },
      metadata: {
        labels: {
          app: "sloop-" + legacyEstate,
          apptype: "monitoring",
          daemonset: "true",
        } + configs.ownerLabel.sam,
        namespace: "sam-system",
      },
    },
  },
  metadata+: {
      labels: {
          name: "sloop-prd-sam",
      } + configs.ownerLabel.sam,
      name: "sloop-prd-sam",
  },
} else "SKIP"
