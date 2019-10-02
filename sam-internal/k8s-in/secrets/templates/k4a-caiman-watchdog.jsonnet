local configs = import "config.jsonnet";
local secretconfigs = import "secretsconfig.libsonnet";
local secretsflights = import "secretsflights.libsonnet";
local secretsimages = (import "secretsimages.libsonnet") + { templateFilename:: std.thisFile };
local madkub = (import "secretsmadkub.libsonnet") + { templateFileName:: std.thisFile };

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
    # Watchdogs monitoring individual k4a servers.
    prd11: {
      extraArgs: [
        "-url",
        "https://sec0-kfora1-1-prd.eng.sfdc.net:8443",
      ],
    },
    prd12: {
      extraArgs: [
        "-url",
        "https://sec0-kfora1-2-prd.eng.sfdc.net:8443",
      ],
    },
    prd21: {
      extraArgs: [
        "-url",
        "https://sec0-kfora2-1-prd.eng.sfdc.net:8443",
      ],
    },
    prd22: {
      extraArgs: [
        "-url",
        "https://sec0-kfora2-2-prd.eng.sfdc.net:8443",
      ],
    },
    prdfailover: {
    },
  },
  xrd: {
    # Watchdogs monitoring individual k4a servers.
    xrd11: {
      extraArgs: [
        "-url",
        "https://sec0-kfora1-1-xrd.eng.sfdc.net:8443",
      ],
    },
    xrd12: {
      extraArgs: [
        "-url",
        "https://sec0-kfora1-2-xrd.eng.sfdc.net:8443",
      ],
    },
    xrd21: {
      extraArgs: [
        "-url",
        "https://sec0-kfora2-1-xrd.eng.sfdc.net:8443",
      ],
    },
    xrd22: {
      extraArgs: [
        "-url",
        "https://sec0-kfora2-2-xrd.eng.sfdc.net:8443",
      ],
    },
    xrdfailover: {
    },
  },
};

local getInstanceDataWithDefaults(instanceTag) = (
  local instanceData = instanceMap[configs.kingdom][instanceTag];
  # The instance name (unless provided) is formed as "secretservice-watchdog-<instanceTag>".
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
    url: "https://sec0-kfora1-1-crd.eng.sfdc.net:8443",
    # extraArgs supplies any additional command line parameters that should be provided for this instance.
    extraArgs: [],
  };

  # Override the default instance data with any defined values from instanceData.
  defaultInstanceData + instanceData
);

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
            image: secretsimages.k4aCaimanWatchdog(),
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
              secretconfigs.sfdcloc_node_name_env.name,
              "-argusUrl",
              "%(funnelVIP)s" % configs,
            ] + instanceData.extraArgs,
            env: [
              secretconfigs.function_instance_name_env,
              secretconfigs.function_namespace_env,
              secretconfigs.sfdcloc_node_name_env,
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
      + secretconfigs.samPodSecurityContext,
    },
  },
};

if secretconfigs.k4aCaimanWdEnabled && std.objectHas(instanceMap, configs.kingdom) then {
  apiVersion: "v1",
  kind: "List",
  metadata: {},
  items: [
    k4aWatchdogDeployment(instanceTag)
    for instanceTag in std.objectFields(instanceMap[configs.kingdom])
  ],
} else "SKIP"
