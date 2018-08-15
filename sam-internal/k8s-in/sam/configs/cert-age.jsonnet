local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then
std.prune({
"cert_age.sh": "#!/bin/sh;\nPROC_UPTIME_MIN_SEC=$(ps -o etime= | head -n 1); \nPROC_UPTIME=$(expr $(expr $(echo $PROC_UPTIME_MIN_SEC | cut -d: -f1) * 60) + $(echo $PROC_UPTIME_MIN_SEC | cut -d: -f2)); \nCERT_AGE=$(echo $((($(date +%s) - $(date +%s -r \"/etc/pki_service/kubernetes/chain-client.pem\")))));\nDIFF=$(expr $PROC_UPTIME - $CERT_AGE);\nexpr $DIFF \\< 60 && echo \"Process certs are older than process. Probably healthy.\" && exit 0;\necho \"Certs older than process. Probably unhealthy\" && exit 1;",
}) else "SKIP"
