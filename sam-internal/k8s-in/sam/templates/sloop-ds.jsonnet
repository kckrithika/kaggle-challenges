local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local sloop = import "configs/sloop-config.jsonnet";

local estateContainer(estate) = {
  name: "sloopds-" + estate,
  resources: {
    requests: self.limits,
    limits: sloop.estateConfigs[estate].resource.limits,
  },
  args: [
    "--config=/sloopconfig/sloop.yaml",
    "--port=" + sloop.estateConfigs[estate].containerPort,
    "--display-context=" + estate,
    "--apiserver-host=http://pseudo-kubeapi.csc-sam.prd-sam.prd.slb.sfdc.net:40001/" + estate + "/",
    # Default maximum history stored - 2 weeks
    "--max-look-back=336h",
  ] + sloop.estateConfigs[estate].resource.flags,
  command: [
    "/sloop",
  ],
  livenessProbe: {
    httpGet: {
      path: "/healthz",
      port: sloop.estateConfigs[estate].containerPort,
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
      port: sloop.estateConfigs[estate].containerPort,
    },
    timeoutSeconds: 5,
  },
  image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/sjawad/sloop:sjawad-20200220_160659-e77a2d5",
  volumeMounts: [
    {
      name: "sloop-data",
      mountPath: "/data/" + estate,
    },
    {
      name: "sloopconfig",
      mountPath: "/sloopconfig/",
    },
  ],
  ports: [
    {
      containerPort: sloop.estateConfigs[estate].containerPort,
      protocol: "TCP",
    },
  ],
};

if samfeatureflags.sloop then configs.daemonSetBase("sam") {
  spec+: {
    template: {
      spec: {
        serviceAccountName: "sloop",
        containers: [
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
        ] + [estateContainer(est) for est in samfeatureflags.sloopEstates[configs.estate]],
        volumes+: [
          {
            hostPath: {
              path: "/data/sloop-data/",
            },
            name: "sloop-data",
          },
          {
            hostPath: {
              path: "/data/sloop-prom-data/",
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
          app: "sloopds",
          apptype: "monitoring",
          daemonset: "true",
        } + configs.ownerLabel.sam,
        namespace: "sam-system",
      },
    },
  },
  metadata+: {
      labels: {
          name: "sloopds",
      } + configs.ownerLabel.sam,
      name: "sloopds",
  },
} else "SKIP"
