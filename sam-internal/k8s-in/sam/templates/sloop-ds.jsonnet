local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

# Node Selector for sloop deployment depending on hosting estate.
local sloopNodeSelectors = {
  "prd-samtest": { master: "true" },
  "prd-samtwo": { "node.sam.sfdc.net/role": "samcompute", pool: "prd-samtwo" },
};

local resourceRequirements = {
  extra_small: {
    cpu: "1",
    memory: "1Gi",
  },
  small: {
    cpu: "1",
    memory: "2Gi",
  },
  medium: {
    cpu: "2",
    memory: "5Gi",
  },
  large: {
    cpu: "3",
    memory: "15Gi",
  },
};

local kingdomResourceRequirements = {
  "prd-samtest": resourceRequirements.small,
  "prd-samtwo": resourceRequirements.medium,
  "hnd-sam": resourceRequirements.medium,
  "frf-sam": resourceRequirements.medium,
  "par-sam": resourceRequirements.large,
  "prd-sam": resourceRequirements.large,
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
              limits: kingdomResourceRequirements[estate],
            },
            args: [
              "--config=/sloopconfig/sloop.yaml",
              "--port=" + portconfigs.sloop.sloop,
              "--display-context=" + estate,
              "--apiserver-host=http://pseudo-kubeapi.csc-sam.prd-sam.prd.slb.sfdc.net:40001/" + estate + "/",
              # Default maximum history stored - 2 weeks
              "--max-look-back=336h",
            ] + (if configs.estate == "prd-samtwo" && estate == "frf-sam" then ["--badger-use-lsm-only-options=false"] else []),
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
            image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/sjawad/sloop:sjawad-20200213_140207-c374987",
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
