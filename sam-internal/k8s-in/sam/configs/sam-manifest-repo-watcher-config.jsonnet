local configs = import "config.jsonnet";

if configs.estate == "prd-samdev" then

std.prune({
        "tnrp-endpoint": "https://ops0-piperepo1-0-prd.data.sfdc.net/",
        "tnrp-bot-account-names": ["svc-tnrp-git-rw", "svc-tnrp-git"],
        "tnrp-scan-frequency": "10m",
        "db-hostname": "10.251.156.174",
        "db-username": "root",
        "db-password-file": "/var/mysqlPwd/pass.txt",
        "db-name": "sam_manifest_repo_watcher_dev",
        "git-url": "https://git.soma.salesforce.com/api/v3/",
        "pr-table-name": "pr_table",
        "pr-to-teamoruser-table-name": "pr_to_teamoruser_table",
        "ghe-tokenfile": "/var/token/token",
        "webhook-tokenfile": "/var/webhook-token/webhook-token",
        "funnel-endpoint": "ajna0-funnel1-0-prd.data.sfdc.net:80",
}) else "SKIP"
