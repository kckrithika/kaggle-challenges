local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then
({
  commands: {
    patch: "cat /etc/sfdc-release | grep -oP '(?<=INSTALL ).*'",
  },
  runFreq: "10m",
  timeout: "1m",
  resync: "30m",
}) else "SKIP"