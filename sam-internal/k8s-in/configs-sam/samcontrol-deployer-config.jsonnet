local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

{
  "funnelEndpoint": configs.funnelVIP,
  "disable-security-check": true,
  "tnrp-endpoint": configs.tnrpArchiveEndpoint,
  "dry-run": false,
  "poll-delay": 30000000000,
  "email": configs.samcontrol_deployer_EmailNotify,
  "email-delay": 0,
  "smtp-server": configs.smtpServer,
  "sender": "sam@salesforce.com",
  "recipient": "sam@salesforce.com",
  "ca-file": configs.caFile,
  "key-file": configs.keyFile,
  "cert-file": configs.certFile,
  "resource-progression-timeout": 120000000000,
  "resource-cooldown": 15000000000,
  "max-resource-time": 300000000000,
}
+ if configs.kingdom == "prd" then {
  "recipient": "sam@salesforce.com,slb@salesforce.com"
} else {
}
