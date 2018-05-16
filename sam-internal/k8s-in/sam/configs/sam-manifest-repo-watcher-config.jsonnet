local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then
std.prune({
        "tnrp-endpoint": configs.tnrpEndpoint,
        "tnrp-bot-account-names": ["svc-tnrp-git-rw", "svc-tnrp-git"],
        "tnrp-scan-frequency": "10m",
        "db-hostname": "mysql.csc-sam." + configs.estate + ".prd.slb.sfdc.net",
        "db-username": "root",
        "db-password-file": "/var/mysqlPwd/pass.txt",
        "db-name": "sam_manifest_repo_watcher",
        "git-url": "https://git.soma.salesforce.com/api/v3/",
        "ghe-tokenfile": "/var/token/token",
        "webhook-tokenfile": "/var/webhook-token/webhook-token",
        "funnel-endpoint": configs.funnelVIP,
}) else "SKIP"
