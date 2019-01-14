local configs = import "config.jsonnet";
local mysql = import "sammysqlconfig.jsonnet";

if configs.estate == "prd-sam" then
std.prune({
        "tnrp-endpoint": configs.tnrpEndpoint,
        "tnrp-bot-account-names": ["svc-tnrp-git-rw", "svc-tnrp-git"],
        "tnrp-bot-scan-frequency": "30s",
        "db-hostname": mysql.readWriteHostName,
        "db-username": "mani-repo-watch",
        "db-password-file": "/var/mysqlPwd/mani-repo-watch",
        "db-name": mysql.visibilityDBName,
        "git-url": "https://git.soma.salesforce.com/api/v3/",
        "ghe-tokenfile": "/var/token/token",
        "webhook-tokenfile": "/var/webhook-token/webhook-token",
        "funnel-endpoint": configs.funnelVIP,
        "look-back": "24h",
        "full-scan-on": false,
        "freq-scan-on": true,
        "tnrp-scan-on": true,
        "pool-map-scan-on": true,
        "pool-map-scan-frequency": "900s",
        "webhook-on": true,
        "pr-scan-frequency": "1800s",
        "num-worker-threads": 5,
        "maximum-github-calls-per-second": 5,
        "enable-pr-commenter": true,
        "sdp-root-url": "http://sdp2.csc-sam.prd-sam.prd.slb.sfdc.net",
        "commenter-test-mode": true,
        "commenter-test-mode-authors": ["benjamin-caldwell"],
        "pr-evaluate-passed-regex": "SUCCESSFUL RUN.",
        "pr-approval-link-regex": "Good news! Authorizing Pull Requests is now done through native GHE Approvals instead of clicking on an Authorization link in the PR",
}) else "SKIP"
