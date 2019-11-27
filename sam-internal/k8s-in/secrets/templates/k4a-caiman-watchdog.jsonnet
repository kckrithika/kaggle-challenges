local configs = import "config.jsonnet";
local secretsconfigs = import "secretsconfig.libsonnet";
local secretsimages = (import "secretsimages.libsonnet") + { templateFilename:: std.thisFile };
local madkub = (import "secretsmadkub.libsonnet") + { templateFileName:: std.thisFile };
local secretsflights = (import "secretsflights.jsonnet");
local utils = import "util_functions.jsonnet";

local certDirs = ["client-certs"];

local build_server_url(tag, kingdom, port=8443) = (
    local domain = if utils.is_test_cluster(configs.estate) then "eng" else "ops";
    "https://sec0-kfora%s-%s.%s.sfdc.net:%d" % [tag, kingdom, domain, port]
);

# Most kingdoms have four nodes (1-1, 1-2, 2-1, 2-2).
# A select few kingdoms have fewer than four, see
# https://argus-ui.data.sfdc.net/argus/#/viewmetrics?expression=ALIAS(GROUPBY(-90d:system.*.NONE.k4a:uptime.uptime%7Bdevice%3D*kfora*%7D:max:1h-max,%23system%5C.(%5BA-Z0-9%5D%7B3%7D)%5C.%23,%23COUNT%23),%20%23up-nodes%23,%20%23literal%23)
# Only monitor instances that are available in each kingdom.
local getKingdomServerSpecificInstances(kingdom=configs.kingdom) = (
if kingdom == "xrd" then {
  local stagingClusterPort = 8444,
  xrd11: { url: build_server_url("1-1", kingdom, stagingClusterPort) },
  xrd12: { url: build_server_url("1-2", kingdom, stagingClusterPort) },
  xrd21: { url: build_server_url("2-1", kingdom, stagingClusterPort) },
  xrd22: { url: build_server_url("2-2", kingdom, stagingClusterPort) },
} else if kingdom == "dfw" then {
  dfw11: { url: build_server_url("1-1", kingdom) },
} else if kingdom == "chi" then {
  chi11: { url: build_server_url("1-1", kingdom) },
  chi12: { url: build_server_url("1-2", kingdom) },
} else if kingdom == "wax" then {
  wax12: { url: build_server_url("1-2", kingdom) },
  wax21: { url: build_server_url("2-1", kingdom) },
  wax22: { url: build_server_url("2-2", kingdom) },
} else {
  [kingdom + "11"]: { url: build_server_url("1-1", kingdom) },
  [kingdom + "12"]: { url: build_server_url("1-2", kingdom) },
  [kingdom + "21"]: { url: build_server_url("2-1", kingdom) },
  [kingdom + "22"]: { url: build_server_url("2-2", kingdom) },
}
);

# Some legacy (non-Jackson) datacenters have K4A, but do not have a SAM presence.
# We still want to monitor K4A in those datacenters; we will do so from one of the sites
# listed as a failover site in the Caiman `config.json` (https://git.soma.salesforce.com/GRaCE/caiman/blob/master/caiman-vault/src/main/resources/config.json):
local getServerSpecificInstancesForLegacyFailoverSites() = (
    # Monitor chi from phx.
    if configs.kingdom == "phx" then getKingdomServerSpecificInstances("chi")
    # Monitor lon from frf.
    else if configs.kingdom == "frf" then getKingdomServerSpecificInstances("lon")
    # Monitor crd from prd.
    else if configs.kingdom == "prd" then getKingdomServerSpecificInstances("crd")
    else {}
);

local getKingdomDefaultInstances = {
    [configs.kingdom + "failover"]: {},
} + getKingdomServerSpecificInstances(configs.kingdom)
   + getServerSpecificInstancesForLegacyFailoverSites();


local getInstanceDataWithDefaults(instanceTag) = (
  local instanceData = getKingdomDefaultInstances[instanceTag];

  # The instance name (unless provided) is formed as "k4a-caiman-watchdog-<instanceTag>".
  local name = (if std.objectHas(instanceData, "name") then instanceData.name else "k4a-caiman-watchdog-" + instanceTag);

  # defaultInstanceData supplies the schema and default values for instanceData.
  local defaultInstanceData = {
    # role indicates the maddog role that is requested for the client certs and allowed access to the named vault.
    role: if utils.is_test_cluster(configs.estate) then "secrets.k4a-watchdog" else "secrets.k4a-watchdog-prod",
    # name is the name of the container for the instance.
    name: name,
    # secretsFile is the file path to the encrypted file
    secretsFile: if utils.is_test_cluster(configs.estate) then "/caiman-watchdog/classes/sam.secrets.k4a-watchdog.zip"
    else "/caiman-watchdog/classes/sam.secrets.k4a-watchdog-prod.zip",
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
# IP address instead of the pod's IP address and fails the request. So we need to use hostnetwork in gia.
# For other sites we want to run the Caiman watchdog on host network to minimize the number of IP addresses
# we consume.
local hostNetworkIfEnabled(canary) = if utils.is_gia(configs.kingdom) || secretsflights.caimanWdSecondReplicaEnabled(canary) then { hostNetwork: true } else {};

local podAntiAffinityIfEnabled(podLabel, canary) = if secretsflights.caimanWdSecondReplicaEnabled(canary) then {
  affinity: {
     podAntiAffinity: {
        requiredDuringSchedulingIgnoredDuringExecution: [{
           labelSelector: {
             matchExpressions: [{
                key: "name",
                operator: "In",
                values: [
                  podLabel,
                ],
             }],
           },
        topologyKey: "kubernetes.io/hostname",
      }],
     },
  },
} else {};

# Temporarily override the node selector in the staging cluster so that our watchdog can communicate with
# the staging cluster's port (8444). Once ACL changes are in place to permit access to port 8444 from
# other estates, we can remove the override.
local nodeSelector =
  if configs.kingdom == "xrd" then {
    nodeSelector: {
      pool: "xrd-slb",
    },
  } else secretsconfigs.nodeSelector;

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
    replicas: if secretsflights.caimanWdSecondReplicaEnabled(instanceData.canary) then 2 else 1,
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
      + nodeSelector
      + secretsconfigs.samPodSecurityContext
      + hostNetworkIfEnabled(instanceData.canary)
      + podAntiAffinityIfEnabled(instanceData.name, instanceData.canary),
    },
  },
};

# If there's only a single instance defined for a datacenter (as there will be for most datacenters),
# don't use the k8s List abstraction; the SAM infrastructure isn't fully aware of the List abstraction,
# so some things break in surprising ways (like image promotion -- new images within a List aren't
# automatically promoted by Firefly, so unless promoted through some side channel the ss-watchdog
# images weren't ending up in prod when encapsulated in a List).
local manifestSpec =
  if configs.estate == "prd-samtwo" then "SKIP"
  else if configs.estate == "prd-sam" || configs.estate == "xrd-sam" || !utils.is_test_cluster(configs.estate) then {
  apiVersion: "v1",
  kind: "List",
  metadata: {},
  items: [
    k4aWatchdogDeployment(instanceTag)
    for instanceTag in std.objectFields(getKingdomDefaultInstances)
    ],
 } else "SKIP";

manifestSpec
