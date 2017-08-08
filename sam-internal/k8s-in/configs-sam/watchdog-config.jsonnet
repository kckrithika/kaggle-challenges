local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

{
  # Shared
  caFile: configs.caFile,
  keyFile: configs.keyFile,
  certFile: configs.certFile,
  tlsEnabled: true,
  funnelEndpoint: configs.funnelVIP,
  rcImtEndpoint: configs.rcImtEndpoint,
  smtpServer: configs.smtpServer,
  sender: configs.watchdog_emailsender,
  recipient: configs.watchdog_emailrec,

  # K8s checker
  k8sproxyEndpoint: "http://localhost:40000",
  # Puppet
  maxUptimeSampleSize: 5,
  # Pod
  podNamespacePrefixBlacklist: "sam-watchdog",  
  # Sdp
  sdpEndpoint: "http://localhost:39999",
  # Synthetic
  laddr: "0.0.0.0:8083",
  imageName: samimages.hypersam,
  # Snoozes
  snooze: [
    { estates: ["prd-samtest"], checker: "hairpinChecker", until: "2017/06/02" },
    { estates: ["prd-samtest"], checker: "kubeApiChecker", until: "2017/06/02" },
  ]
} + 
(
  if configs.kingdom == "prd" then {
    deploymentNamespacePrefixWhitelist: "sam-system,csc-sam" 
  } else {}
)
