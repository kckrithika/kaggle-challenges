local configs = import "config.jsonnet";


{
  commands: {
    osPatch: "cat /etc/sfdc-release | grep -oP '(?<=INSTALL ).*'",
  },
  runFreq: "10m",
  timeout: "1m",
  resync: "30m",
  livenessProbePort: "21690",
}
