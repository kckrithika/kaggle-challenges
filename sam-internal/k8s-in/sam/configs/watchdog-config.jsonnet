local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";
local utils = import "util_functions.jsonnet";

{
  # Snoozes - This is a central list of all snoozed watchdogs.  For each snooze, please add a comment explaining the reason
  # Format of struct is here: https://git.soma.salesforce.com/sam/sam/blob/master/pkg/tools/watchdog/internal/config/config.go
  # Fields `estates`, `checker`, and `until` are required.  Specific instances can be listed with `instances` or using regex with `instanceRegex`
  # Until date format is YYYY/MM/DD.
  #
  # Example: { estates: ["prd-samtest"], checker: "hairpinChecker", until: "2017/06/02" },
  snooze: [
    # Unknown - next time add comment
    { estates: ["iad-sam"], checker: "nodeChecker", until: "2017/09/15" },
    { estates: ["iad-sam"], checker: "podChecker", until: "2017/09/15" },
    { estates: ["iad-sam"], checker: "deploymentChecker", until: "2017/09/15" },
    # [thargrove] Watchdog was crashing because of yaml pkg switch
    { estates: ["prd-sam", "prd-samtest", "prd-samdev"], checker: "estatesvcChecker", until: "2017/10/01" },
    # [thargrove] TNRP changed bot name
    { estates: ["prd-sam"], checker: "prChecker", until: "2017/10/01" },
    { estates: ["prd-sam", "prd-samtest", "prd-samdev", "prd-sam_storage"], checker: "hairpinChecker", until: "2017/11/01" },
    { estates: ["prd-sam", "prd-samtest", "prd-samdev", "prd-sam_storage"], checker: "bridgeChecker", until: "2017/11/01" },
    # [xiao] Pending hypsersam prod release
    { estates: ["phx-sam"], checker: "nodeChecker", until: "2017/11/30" },
    ] + (
    # Dont change prod
    # 1.7.4 update triggered veth problems. Fixed in all non-flannel estates. Pending fix for flannel estates
    if configs.kingdom == "prd" then [
    { estates: ["prd-sam_cloudatlas", "prd-sam_cloudatlas_dir"], checker: "hairpinChecker", until: "2017/11/21" },
    ] else []
    ),

  # Shared
  "email-subject-prefix": "SAMWD",
  caFile: configs.caFile,
  keyFile: configs.keyFile,
  certFile: configs.certFile,
  tlsEnabled: true,
  funnelEndpoint: configs.funnelVIP,
  rcImtEndpoint: configs.rcImtEndpoint,
  smtpServer: configs.smtpServer,
  sender: $.recipient,
  recipient: (
        if configs.estate == "prd-sdc" then "sdn@salesforce.com"
        else if configs.estate == "prd-sam_storage" then "storagefoundation@salesforce.com"
        else if configs.estate == "prd-samdev" then ""
        else if configs.estate == "prd-samtest" then ""
        else if configs.kingdom == "prd" then "sam-test-alerts@salesforce.com"
        else "sam-alerts@salesforce.com"
  ),

  # Hairpin deployer
  "deployer-sender": $.recipient,
  "deployer-recipient": $.recipient,
  "deployer-imageName": samimages.hypersam,
  "deployer-funnelEndpoint": configs.funnelVIP,
  "deployer-rcImtEndpoint": configs.rcImtEndpoint,
  "deployer-smtpServer": configs.smtpServer,

  # K8s checker
  k8sproxyEndpoint: "http://localhost:40000",
  # Puppet
  maxUptimeSampleSize: 5,

  # Sdp
  sdpEndpoint: "http://localhost:39999",
  # Synthetic
  laddr: "0.0.0.0:8083",
  imageName: samimages.hypersam,
  # Maddog checker
  maddogServerCAPath: configs.maddogServerCAPath,
  # processstarttime checker
  monitoredProcesses: {
    "hyperkube.*kubelet": "age.kubelet",
    "hyperkube.*proxy": "age.kubeproxy",
    "hyperkube.*controller-manager": "age.kubecontrollermanager",
    "hyperkube.*apiserver": "age.kubeapiserver",
    "hyperkube.*scheduler": "age.kubescheduler",
    "dockerd.*docker-bootstrap": "age.dockerbootstrap",
    "dockerd.*docker.sock": "age.dockermain",
  },
} +
(
  if configs.kingdom == "prd" then {
  # Kuberesource Checker
  # We dont want to report on broken hairpin pods, since hairpin already alerts on those
  # PRD is very noisy with lots of bad customer deployments and pods, so for now just focus on our control stack
      kubeResourceNamespacePrefixBlacklist: "sam-watchdog",
      kubeResourceNamespacePrefixWhitelist: "sam-system,csc-sam",
      deploymentNamespacePrefixWhitelist: "sam-system",
  } else {
    podNamespacePrefixBlacklist: "sam-watchdog",
  }
) + (if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    enableStatefulChecks: true,
  } else {})
  + (if !utils.is_public_cloud(configs.kingdom) then {
    enableMaddogCertChecks: true,
  } else {})
  + (if configs.estate == "prd-sam" then {
    storageClassName: "synthetic-hdd-pool",
  } else {})
