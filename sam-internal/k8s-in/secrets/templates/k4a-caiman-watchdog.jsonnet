local configs = import "config.jsonnet";
local secretsconfigs = import "secretsconfig.libsonnet";
local secretsimages = (import "secretsimages.libsonnet") + { templateFilename:: std.thisFile };
local madkub = (import "secretsmadkub.libsonnet") + { templateFileName:: std.thisFile };
local utils = import "util_functions.jsonnet";

local certDirs = ["client-certs"];

local build_server_url(tag) = (
    local urlHead = "https://sec0-kfora";
    local urlTail = if utils.is_test_cluster(configs.estate) then ".eng.sfdc.net:8443" else ".ops.sfdc.net:8443";
    urlHead + tag + urlTail
);

# instanceMap defines the set of watchdog instances that should exist within each kingdom.
# Most kingdoms will just have a single watchdog instance.
# Watchdog instances are deployed to the "<kingdom>-sam" estate for each kingdom where one or
# more watchdog instances should exist.
# This helps deduplicate many of the common boilerplate specs for a watchdog instance, while
# still allowing specialization of specific parameters between watchdog instances in the same
# datacenter.
# The schema is:
# {
#   <kingdomName>: {
#     <instanceTag>: {
#       ... instance data ...
#     },
#     ... additional instances ...
#   },
#   ... additional kingdoms ...
#
# For each instance, the instance data object supplies parameters relevant to the construction
# of that specific instance. Many parameters are defaulted by getInstanceDataWithDefaults
# below. which also serves to roughly outline the schema for the instance data.
local instanceMap = {
  prd: {
    # Watchdogs monitoring individual k4a servers.
    prd11: {
      url: build_server_url("1-1-prd"),
    },
    prd12: {
      url: build_server_url("1-2-prd"),
    },
    prd21: {
      url: build_server_url("2-1-prd"),
    },
    prd22: {
      url: build_server_url("2-2-prd"),
    },
    prdfailover: {
    },
  },
  xrd: {
    # Watchdogs monitoring individual k4a servers.
    xrd11: {
      url: build_server_url("1-1-xrd"),
    },
    xrd12: {
      url: build_server_url("1-2-xrd"),
    },
    xrd21: {
      url: build_server_url("2-1-xrd"),
    },
    xrd22: {
      url: build_server_url("2-2-xrd"),
    },
    xrdfailover: {
    },
  },
  phx: {
   # Watchdogs monitoring individual k4a servers.
    phx11: {
      url: build_server_url("1-1-phx"),
    },
    phx12: {
      url: build_server_url("1-2-phx"),
    },
    phx21: {
      url: build_server_url("2-1-phx"),
    },
    phx22: {
      url: build_server_url("2-2-phx"),
    },
    phxfailover: {
    },
  },
  dfw: {
      # Watchdogs monitoring individual k4a servers.
      dfw11: {
        url: build_server_url("1-1-dfw"),
      },
      dfw12: {
        url: build_server_url("1-2-dfw"),
      },
      dfw21: {
        url: build_server_url("2-1-dfw"),
      },
      dfw22: {
        url: build_server_url("2-2-dfw"),
      },
      dfwfailover: {
      },
    },
};

local getInstanceDataWithDefaults(instanceTag) = (
  local instanceData = instanceMap[configs.kingdom][instanceTag];
  # The instance name (unless provided) is formed as "k4a-caiman-watchdog-<instanceTag>".
  local name = (if std.objectHas(instanceData, "name") then instanceData.name else "k4a-caiman-watchdog-" + instanceTag);

  # defaultInstanceData supplies the schema and default values for instanceData.
  local defaultInstanceData = {
    # role indicates the maddog role that is requested for the client certs and allowed access to the named vault.
    role: "secrets.k4a-watchdog",
    # name is the name of the container for the instance.
    name: name,
    # secretsFile is the file path to the encrypted file
    secretsFile: "/caiman-watchdog/classes/sam.secrets.k4a-watchdog.zip",
    # certPath is the location of the mounted Maddog cert
    certPath: "/clientcert",
    # url: is the url of the k4a server
    url: null,
    # extraArgs supplies any additional command line parameters that should be provided for this instance.
    extraArgs: [],
    # canary indicates whether this instance should be considered a "canary" instance. Such instances are targeted
    # first for new deployments.
    canary: false,
  };

  # Override the default instance data with any defined values from instanceData.
  defaultInstanceData + instanceData
);

# When requesting maddog certs for the watchdog in hio/ttd, madkubserver enforces that the request's
# IP address matches the IP address of the requesting pod. However, for non-host network pods, there's
# currently an issue where the request is proxied by the host, so madkubserver ends up seeing the host's
# IP address instead of the pod's IP address and fails the request.
# As a workaround, use host network for the pod in gia. This ensures the pod's IP address matches the
# host's IP address, and madkubserver thus allows the request.
local hostNetworkIfGia = if utils.is_gia(configs.kingdom) then { hostNetwork: true } else {};

local k4aWatchdogDeployment(instanceTag) = configs.deploymentBase("secrets") {
  local instanceData = getInstanceDataWithDefaults(instanceTag),
  metadata: {
    labels: {
      name: instanceData.name,
    } + configs.ownerLabel.secrets,
    name: instanceData.name,
    namespace: "sam-system",
  },
  spec+: {
    replicas: 1,
    template: {
      metadata: {
        annotations: {
        } + madkub.certsAnnotation(instanceData.role),
        labels: {
          name: instanceData.name,
        } + configs.ownerLabel.secrets,
        namespace: "sam-system",
      },
      spec: {
        containers: [
          {
            name: "watchdog",
            image: secretsimages.k4aCaimanWatchdog(instanceData.canary),
            args: [
              "java",
              "-Duser.home=/tmp",
              "-jar",
              "/caiman-watchdog/caiman-watchdog-0.0.15-SNAPSHOT.jar",
              "-secretsFile",
              "%(secretsFile)s" % instanceData,
              "-certPath",
              "%(certPath)s" % instanceData,
              "-datacenter",
              configs.kingdom,
              "-hostname",
              "$(" + secretsconfigs.sfdcloc_node_name_env.name + ")",
              "-argusUrl",
              "http://%(funnelVIP)s" % configs,
            ] + (if instanceData.url != null then
            [
              "-url",
              "%(url)s" % instanceData,
            ] else []) + instanceData.extraArgs,
            env: [
              secretsconfigs.function_instance_name_env,
              secretsconfigs.function_namespace_env,
              secretsconfigs.sfdcloc_node_name_env,
            ],
            volumeMounts: madkub.certVolumeMounts,
          } + configs.ipAddressResourceRequest,
          madkub.refreshContainer,
        ],
        initContainers: [
          madkub.initContainer,
        ],
        volumes: madkub.volumes + madkub.certVolumes,
      }
      + configs.nodeSelector
      + secretsconfigs.samPodSecurityContext
      + hostNetworkIfGia,
    },
  },
};

local instanceTagsForKingdom = if std.objectHas(instanceMap, configs.kingdom) then std.objectFields(instanceMap[configs.kingdom]);
# If there's only a single instance defined for a datacenter (as there will be for most datacenters),
# don't use the k8s List abstraction; the SAM infrastructure isn't fully aware of the List abstraction,
# so some things break in surprising ways (like image promotion -- new images within a List aren't
# automatically promoted by Firefly, so unless promoted through some side channel the ss-watchdog
# images weren't ending up in prod when encapsulated in a List).
local manifestSpec =
  if !secretsconfigs.k4aCaimanWdEnabled || instanceTagsForKingdom == null || std.length(instanceTagsForKingdom) == 0 then "SKIP"
  else if std.length(instanceTagsForKingdom) == 1 then k4aWatchdogDeployment(instanceTagsForKingdom[0])
  else {
  apiVersion: "v1",
  kind: "List",
  metadata: {},
  items: [
    k4aWatchdogDeployment(instanceTag)
    for instanceTag in std.objectFields(instanceMap[configs.kingdom])
  ],
};

manifestSpec
