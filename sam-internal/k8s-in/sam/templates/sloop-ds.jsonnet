local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

# Node Selector for sloop deployment depending on hosting estate.
local sloopNodeSelectors = {
  "prd-sam": { master: "true" },
  "prd-samtwo": { "node.sam.sfdc.net/role": "samcompute", pool: "prd-samtwo" },
};

local makeds(estate) = configs.daemonSetBase("sam") {
  spec+: {
    template: {
      spec: {
        serviceAccountName: "sloop",
        containers: [
          {
            name: "sloopds",
            resources: {
              requests: self.limits,
              limits: {
                cpu: "1",
                memory: "12Gi",
              },
            },
            args: [
              "--config=/sloopconfig/sloop.yaml",
              "--port=" + portconfigs.sloop.sloop,
              "--display-context=" + estate,
              "--apiserver-host=http://pseudo-kubeapi.csc-sam.prd-sam.prd.slb.sfdc.net:40001/" + estate + "/",
              # Default maximum history stored - 2 weeks
              "--max-look-back=336h",
            ],
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
            image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/sjawad/sloop:sjawad-20200204_102504-bbd2691",
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
                path: "/data/sloop-data/" + estate,
            },
            name: "sloop-data",
          },
          {
            hostPath: {
                path: "/data/sloop-prom-data/" + estate,
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
          sloopNodeSelectors[configs.estate],
      },
      metadata: {
        labels: {
          app: "sloopds-" + estate,
          apptype: "monitoring",
          daemonset: "true",
        } + configs.ownerLabel.sam,
        namespace: "sam-system",
      },
    },
  },
  metadata+: {
      labels: {
          name: "sloopds-" + estate,
      } + configs.ownerLabel.sam,
      name: "sloopds-" + estate,
  },
};

if samfeatureflags.sloop then {
  apiVersion: "v1",
  kind: "List",
  metadata: {
      namespace: "sam-system",
  },
  items: [makeds(x) for x in samfeatureflags.sloopEstates[configs.estate]],
} else "SKIP"
