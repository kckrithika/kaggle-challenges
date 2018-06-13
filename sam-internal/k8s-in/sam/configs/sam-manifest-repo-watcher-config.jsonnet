local configs = import "config.jsonnet";
local mysql = import "sammysqlconfig.jsonnet";

if configs.estate == "prd-sam" then
std.prune({
        "tnrp-endpoint": configs.tnrpEndpoint,
        "tnrp-bot-account-names": ["svc-tnrp-git-rw", "svc-tnrp-git"],
        "tnrp-bot-scan-frequency": "30s",
        "db-hostname": mysql.hostName,
        "db-username": mysql.userName,
        "db-password-file": "/var/mysqlPwd/pass.txt",
        "db-name": mysql.visibilityDBName,
        "git-url": "https://git.soma.salesforce.com/api/v3/",
        "ghe-tokenfile": "/var/token/token",
        "webhook-tokenfile": "/var/webhook-token/webhook-token",
        "funnel-endpoint": configs.funnelVIP,
        "look-back": "360h",
        "full-scan-on": true,
        "freq-scan-on": true,
        "tnrp-scan-on": true,
        "webhook-on": true,
        "pr-scan-frequency": "60s",
        "num-worker-threads": 50,
        "maximum-github-calls-per-second": 1000,
}) else "SKIP"
