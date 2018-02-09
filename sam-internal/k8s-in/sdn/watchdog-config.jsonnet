local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

{
  # Snoozes - This is a central list of all snoozed watchdogs.  For each snooze, please add a comment explaining the reason
  # Format of struct is here: https://git.soma.salesforce.com/sam/sam/blob/master/pkg/tools/watchdog/internal/config/config.go
  # Fields `estates`, `checker`, and `until` are required.  Specific instances can be listed with `instances` or using regex with `instanceRegex`
  # Until date format is YYYY/MM/DD.
  #
  # Example: { estates: ["prd-samtest"], checker: "hairpinChecker", until: "2017/06/02" },
  snooze: [
    # [thargrove] Example snoozes that existed previously as flags but are expired.  Can be removed next update
    { estates: ["prd-samtest"], checker: "kubeApiChecker", until: "2017/06/02" },
    { estates: ["iad-sam"], checker: "nodeChecker", until: "2017/09/15" },
    { estates: ["iad-sam"], checker: "podChecker", until: "2017/09/15" },
    { estates: ["iad-sam"], checker: "deploymentChecker", until: "2017/09/15" },
    { estates: ["prd-sam", "prd-samtest", "prd-samdev"], checker: "estatesvcChecker", until: "2017/10/01" },
  ],

  # Shared
  caFile: configs.caFile,
  keyFile: configs.keyFile,
  certFile: configs.certFile,
  tlsEnabled: true,
  funnelEndpoint: configs.funnelVIP,
  rcImtEndpoint: configs.rcImtEndpoint,
  smtpServer: configs.smtpServer,
  sender: "sam-alerts@salesforce.com",
  recipient: (
        if configs.estate == "prd-sdc" then "sdn@salesforce.com"
        else if configs.estate == "prd-sam_storage" then "storagefoundation@salesforce.com"
        else if configs.estate == "prd-samdev" then ""
        else if configs.estate == "prd-samtest" then ""
        else if configs.kingdom == "prd" then "sam@salesforce.com"
        else "sam-alerts@salesforce.com"
),

  # K8s checker
  k8sproxyEndpoint: "http://localhost:40000",
  # Puppet
  maxUptimeSampleSize: 5,
  # Pod
  podNamespacePrefixBlacklist: "sam-watchdog",
  # Sdp
  sdpEndpoint: "http://localhost:39999",
  # Synthetic
  laddr: "0.0.0.0:8083",
  imageName: samimages.hypersam,
}
