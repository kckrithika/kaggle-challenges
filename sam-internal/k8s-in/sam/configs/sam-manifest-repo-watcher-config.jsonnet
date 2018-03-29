local configs = import "config.jsonnet";

if configs.estate == "prd-samdev" then

std.prune({
        "tnrp-endpoint": "https://ops0-piperepo1-0-prd.data.sfdc.net/",
        "tnrp-bot-account-name": "svc-tnrp-git-rw",
        "tnrp-scan-frequency": "10m",
        "db-hostname": "10.251.156.116",
        "db-username": "root",
        "db-password-file": "/var/mysqlPwd/pass.txt",
        "db-name": "sam_manifest_repo_watcher_dev",
        "git-url": "https://git.soma.salesforce.com/api/v3/",
        "pr-table-name": "pr_table",
        "pr-to-teamoruser-table-name": "pr_to_teamoruser_table",
        tokenfile: "/var/token/token",
}) else "SKIP"
