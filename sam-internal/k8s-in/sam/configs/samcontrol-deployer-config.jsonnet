local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

{
  funnelEndpoint: configs.funnelVIP,
  "disable-security-check": true,
  "tnrp-endpoint": configs.tnrpArchiveEndpoint,
  "dry-run": false,
  "poll-delay": 30000000000,
  email: true,
  "email-delay": 0,
  "smtp-server": configs.smtpServer,
  sender: "sam@salesforce.com",
  recipient: "sam@salesforce.com",
  "ca-file": configs.caFile,
  "key-file": configs.keyFile,
  "cert-file": configs.certFile,
  "resource-progression-timeout": 120000000000,
  "resource-cooldown": 15000000000,
  "max-resource-time": 300000000000,
  "delete-orphans": true,
  "resources-to-skip": ["sdn-secret.yaml"],
}
+ (if configs.kingdom == "prd" then {
  "daily-deployment-keyword": "auto",
  tokenfile: "/var/token/token",
  "daily-deployment-offset": "3h",
  "daily-deployment-frequency": "6h",
  } else {
})
+ (if configs.estate == "prd-sam_storage" then {
    recipient: "storagefoundation@salesforce.com",
  } else if configs.kingdom == "prd" then {
    recipient: "sam@salesforce.com,slb@salesforce.com",
  } else {
})
