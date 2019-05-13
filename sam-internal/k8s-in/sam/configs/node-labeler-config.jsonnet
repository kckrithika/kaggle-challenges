local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then
({
  commands: {
    osPatch: "cat /etc/sfdc-release | grep -oP '(?<=INSTALL ).*'",
  },
  runFreq: "10m",
  timeout: "1m",
  resync: "30m",
  livenessProbePort: "21690",
}) else "SKIP"
