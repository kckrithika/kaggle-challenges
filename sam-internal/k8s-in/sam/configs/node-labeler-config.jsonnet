local configs = import "config.jsonnet";

local utils = import "util_functions.jsonnet";

if !utils.is_pcn(configs.kingdom) then {
  commands: {
    osPatch: "cat /etc/sfdc-release | grep -oP '(?<=INSTALL ).*'",
  },
  runFreq: "10m",
  timeout: "1m",
  resync: "30m",
  livenessProbePort: "21690",
} else "SKIP"
