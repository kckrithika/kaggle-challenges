local configs = import "config.jsonnet";

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
  recipient: "cbatra@salesforce.com",
  "ca-file": configs.caFile,
  "key-file": configs.keyFile,
  "cert-file": configs.certFile,
  "resource-progression-timeout": 120000000000,
  "resource-cooldown": 15000000000,
  "max-resource-time": 300000000000,
  "disable-rollback": true,
  "etcd-directory": "/temp/secrets/",
  "src-root": "temp-secrets/",
  "delete-orphans": false,
}
