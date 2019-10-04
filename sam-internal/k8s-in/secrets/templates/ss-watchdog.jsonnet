local configs = import "config.jsonnet";
local secretsconfigs = import "secretsconfig.libsonnet";
local secretsimages = (import "secretsimages.libsonnet") + { templateFilename:: std.thisFile };
local madkub = (import "secretsmadkub.libsonnet") + { templateFileName:: std.thisFile };
local utils = import "util_functions.jsonnet";

local certDirs = ["client-certs"];

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
    # Watchdogs monitoring individual CRZ servers.
    crz11: {
      endpoint: "ops-vaultczar1-1-crz.ops.sfdc.net",
      writePort: 8271,
    },
    crz21: {
      endpoint: "ops-vaultczar2-1-crz.ops.sfdc.net",
      writePort: 8271,
    },
    crz12: {
      endpoint: "ops-vaultczar1-2-crz.ops.sfdc.net",
      writePort: 8271,
    },
    crz22: {
      endpoint: "ops-vaultczar2-2-crz.ops.sfdc.net",
      writePort: 8271,
    },
    # Watchdog monitoring the PRD SecretService vips.
    prd: {
      endpoint: "secretservice-prd.data.sfdc.net",
      wdKingdom: "PRD",
      extraArgs: [
        "-enableLifecycleTest=true",
      ],
      canary: true,
    },
    # WD monitoring production DMZ SecretService.
    "dmz-from-prd": {
      endpoint: "secretservice.dmz.salesforce.com",
    },
  },
  xrd: {
    # WD monitoring staging SS.
    "infrasec1test-xrd": {
      endpoint: "secretservice-infrasec1-xrd.data.sfdc.net",
      wdKingdom: "XRD",
      extraArgs: [
        "-enableLifecycleTest=true",
      ],
      canary: true,
    },
    # Watchdog monitoring XRD SecretService.
    xrd: {
      endpoint: "secretservice-xrd.data.sfdc.net",
      wdKingdom: "XRD",
      extraArgs: [
        "-enableLifecycleTest=true",
      ],
      canary: true,
    },
    # WD monitoring production DMZ SecretService
    "dmz-from-xrd": {
      endpoint: "secretservice.dmz.salesforce.com",
    },
  },
  hio: {
    # Watchdog monitoring HIO SecretService.
    hio: {
      endpoint: "secretservice-hio.data.sfdc.net",
      wdKingdom: "HIO",
    },
  },
  ttd: {
    # Watchdog monitoring TTD SecretService.
    ttd: {
      endpoint: "secretservice-ttd.data.sfdc.net",
      wdKingdom: "TTD",
    },
  },
  phx: {
    # WD monitoring production DMZ SecretService.
    "dmz-from-phx": {
      endpoint: "secretservice.dmz.salesforce.com",
    },
  },
  dfw: {
    # WD monitoring production DMZ SecretService.
    "dmz-from-dfw": {
      endpoint: "secretservice.dmz.salesforce.com",
    },
  },
};

local getInstanceDataWithDefaults(instanceTag) = (
  local instanceData = instanceMap[configs.kingdom][instanceTag];
  # The instance name (unless provided) is formed as "secretservice-watchdog-<instanceTag>".
  local name = (if std.objectHas(instanceData, "name") then instanceData.name else "secretservice-watchdog-" + instanceTag);

  # defaultInstanceData supplies the schema and default values for instanceData.
  local defaultInstanceData = {
    # name is the name of the container for the instance.
    name: name,
    # vaultName is the name of the secret service vault that is accessed by the canary instance.
    vaultName: "ss-watchdog-vault-" + instanceTag,
    # role indicates the maddog role that is requested for the client certs and allowed access to the named vault.
    role: "secrets.secretservice-watchdog",
    # wdKingdom indicates the kingdom hosting the target secret service that this watchdog is intended to monitor.
    wdKingdom: "CRZ",
    # writePort supplies the target port for "write" operations performed by this watchdog.
    writePort: 8272,
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

local ssWatchdogDeployment(instanceTag) = configs.deploymentBase("secrets") {
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
            image: secretsimages.sswatchdog(instanceData.canary),
            args: [
              "-ssEndpoint=%(endpoint)s" % instanceData,
              "-ssWritePort=%(writePort)s" % instanceData,
              "-wdKingdom=%(wdKingdom)s" % instanceData,
              "-vaultName=%(vaultName)s" % instanceData,
              "-role=sam.%(role)s" % instanceData,
              "-metricsEndpoint=%(funnelVIP)s" % configs,
              "-logtostderr=true",
            ] + instanceData.extraArgs,
            command: [
              "/secretservice/secretservice-watchdog",
            ],
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
  if !secretsconfigs.isSecretsEstate || instanceTagsForKingdom == null || std.length(instanceTagsForKingdom) == 0 then "SKIP"
  else if std.length(instanceTagsForKingdom) == 1 then ssWatchdogDeployment(instanceTagsForKingdom[0])
  else {
  apiVersion: "v1",
  kind: "List",
  metadata: {},
  items: [
    ssWatchdogDeployment(instanceTag)
    for instanceTag in std.objectFields(instanceMap[configs.kingdom])
  ],
};

manifestSpec
