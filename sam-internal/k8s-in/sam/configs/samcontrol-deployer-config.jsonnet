local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";
std.prune({
  funnelEndpoint: configs.funnelVIP,
  "disable-security-check": true,
  "tnrp-endpoint": configs.tnrpArchiveEndpoint,
  "dry-run": false,
  "poll-delay": (if configs.kingdom == "prd" then "30s" else 30000000000),
  email: !utils.is_pcn(configs.kingdom),
  "email-delay": 0,
  "smtp-server": configs.smtpServer,
  sender: "sam@salesforce.com",
  recipient: (
    if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam_storagedev" then "storagefoundation@salesforce.com"
    else if configs.kingdom == "prd" || configs.kingdom == "frf" || configs.kingdom == "phx" then "sam@salesforce.com,slb@salesforce.com"
    else "sam@salesforce.com"
  ),
  "resource-progression-timeout": (if configs.kingdom == "prd" then "2m" else 120000000000),
  "resource-cooldown": (if configs.estate == "prd-samtest" then "30s" else (if configs.kingdom == "prd" then "15s" else 15000000000)),
  "max-resource-time": "20m",
  "app-key-ttl-duration": "12h",
  "delete-orphans": !utils.is_pcn(configs.kingdom),
  "resources-to-skip": ["sdn-secret.yaml"],

} + if utils.is_pcn(configs.kingdom) then {
    "etcd-override": "http://0.0.0.0:2379",
    "enable-daily-tnrpUpdate": false,
} else {
    "ca-file": configs.caFile,
    "key-file": configs.keyFile,
    "cert-file": configs.certFile,

    # This is a private field which does not go to output (because it has a '::' instead of ':')
    enableDailyDeployment:: (if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then true else false),
    "daily-deployment-keyword": (if self.enableDailyDeployment then "auto"),
    tokenfile: (if self.enableDailyDeployment then "/var/token/token"),
    "daily-deployment-offset": (if self.enableDailyDeployment then "0"),
    "daily-deployment-frequency": (if configs.estate == "prd-samtest" then "24h" else (if configs.estate == "prd-samdev" then "3h")),
})
