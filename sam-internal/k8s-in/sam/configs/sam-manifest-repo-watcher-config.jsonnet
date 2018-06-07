local configs = import "config.jsonnet";
local mysql = import "sammysqlconfig.jsonnet";

if configs.estate == "prd-sam" then
std.prune({
        "tnrp-endpoint": configs.tnrpEndpoint,
        "tnrp-bot-account-names": ["svc-tnrp-git-rw", "svc-tnrp-git"],
        "tnrp-scan-frequency": "5m",
        "db-hostname": mysql.hostName,
        "db-username": mysql.userName,
        "db-password-file": "/var/mysqlPwd/pass.txt",
        "db-name": mysql.visibilityDBName,
        "git-url": "https://git.soma.salesforce.com/api/v3/",
        "ghe-tokenfile": "/var/token/token",
        "webhook-tokenfile": "/var/webhook-token/webhook-token",
        "funnel-endpoint": configs.funnelVIP,
        "full-scan-on": true,
        "freq-scan-on": true,
        "webhook-on": true,
        "num-worker-threads": 50,
        "maximum-github-calls-per-second": 1000,
}) else "SKIP"
