local configs = import "config.jsonnet";

std.prune({
        "tnrp-endpoint": "https://ops0-piperepo1-0-prd.data.sfdc.net/",
        "tnrp-bot-account-name": "svc-tnrp-git-rw",
        "tnrp-scan-frequency": "10m",
        "db-hostname": "someDBHostname",
        "db-username": "someDBUsername",
        "db-password-file": "somefile.txt",
        "db-name": "someDBName",
})
