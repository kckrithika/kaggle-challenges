local configs = import "config.jsonnet";
local mysql = import "sammysqlconfig.jsonnet";

if configs.estate == "prd-sam" then
std.prune({
        "enable-case-validator": true,
        "num-worker-threads": 5,
        "git-url": "https://git.soma.salesforce.com/api/v3/",
        "git-org": "sam",
        "git-repo": "test-manifests",
        "ghe-tokenfile": "/etc/git-secret/github-token.txt",
        "gus-secrets-folder": "/etc/gus-secrets",
        "webhook-tokenfile": "/etc/webhook-secret/webhook-token.txt",
        "webhook-on": true,
}) else "SKIP"
