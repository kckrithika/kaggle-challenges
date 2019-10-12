local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local samwdconfig = import "samwdconfig.jsonnet";
local utils = import "util_functions.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

std.prune({
  # Snoozes - This is a central list of all snoozed watchdogs.  For each snooze, please add a comment explaining the reason
  # Format of struct is here: https://git.soma.salesforce.com/sam/sam/blob/master/pkg/tools/watchdog/internal/config/config.go
  # Fields `estates`, `checker`, and `until` are required.  Specific instances can be listed with `instances` or using regex with `instanceRegex`
  # Until date format is YYYY/MM/DD.
  #
  # Example: { estates: ["prd-samtest"], checker: "hairpinChecker", until: "2017/06/02" },
  snooze: [
    #[a.mitra] rbac is disabled in prd-sam for k8s upgrade. snoozing alerts for now
    { instanceRegex: "-frf.ops.sfdc.net$", checker: "rbacChecker", until: "2018/06/12" },
    #[karim] maddog isn't up in lo2/l03 yet so synthetic always fails,
    { estates: ["lo2-sam", "lo3-sam"], checker: "syntheticChecker", until: "2019/01/07" },
    ],

  # Shared
  "email-subject-prefix": "SAMWD",
  caFile: configs.caFile,
  keyFile: configs.keyFile,
  certFile: configs.certFile,
  tlsEnabled: true,
  funnelEndpoint: configs.funnelVIP,
  rcImtEndpoint: configs.rcImtEndpoint,
  smtpServer: configs.smtpServer,
  sender: samwdconfig.sender,
  recipient: samwdconfig.recipient,

  # Watchdog CRD
  publishToWatchDogCrd: true,

  # Hairpin deployer
  "deployer-sender": $.sender,
  "deployer-recipient": $.recipient,
  "deployer-imageName": samimages.hypersam,
  "deployer-funnelEndpoint": configs.funnelVIP,
  "deployer-rcImtEndpoint": configs.rcImtEndpoint,
  "deployer-smtpServer": configs.smtpServer,

  # K8s checker
  k8sproxyEndpoint: "http://localhost:40000",
  # Puppet
  maxUptimeSampleSize: 5,
  #sdn
  sdpEndpoint: (if configs.estate == "prd-sam" then "http://sdp.sam-system." + configs.estate + ".prd.slb.sfdc.net:64121" else "http://localhost:39999"),

  # Synthetic
  laddr: (if configs.estate == "prd-sam" then "0.0.0.0:8063" else "0.0.0.0:8083"),
  imageName: samimages.hypersam,
  # Maddog checker
  maddogServerCAPath: configs.maddogServerCAPath,
  # processstarttime checker
  monitoredProcesses: {
    "hyperkube.*kubelet": "age.kubelet",
    "hyperkube.*proxy": "age.kubeproxy",
    "hyperkube.*controller-manager": "age.kubecontrollermanager",
    "hyperkube.*apiserver": "age.kubeapiserver",
    "hyperkube.*scheduler": "age.kubescheduler",
    "dockerd.*docker-bootstrap": "age.dockerbootstrap",
    "dockerd.*docker.sock": "age.dockermain",
    "docker-containerd.*docker-containerd.sock": "age.dockercontainerd",
    "docker-containerd.*docker-bootstrap": "age.dockercontainerdbootstrap",
    "name=etcd": "age.etcd",
    "illumio_ven/.*Agent": "age.illumio.Agent",  # eg. /opt/illumio_ven/bin/AgentMonitor
  },

  m_tnrpEndpoint: (if configs.kingdom == "prd" then configs.tnrpEndpoint),

  # Kuberesource Checker
  # We dont want to report on broken hairpin pods, since hairpin already alerts on those
  # PRD is very noisy with lots of bad customer deployments and pods, so for now just focus on our control stack
  kubeResourceNamespacePrefixBlacklist: (if configs.kingdom == "prd" then "sam-watchdog"),
  kubeResourceNamespacePrefixWhitelist: (if configs.kingdom == "prd" then "sam-system,csc-sam"),
  deploymentNamespacePrefixWhitelist: (if configs.kingdom == "prd" then "sam-system"),
  podNamespacePrefixBlacklist: (if configs.kingdom != "prd" then "sam-watchdog"),

  # This is special as in only  RDI Ceph Is supported
  # This will goaway slowly
  storageClassName: (if configs.estate == "prd-samdev" then "standard"),
  enableK4aChecks: (if configs.estate == "prd-samtest" || configs.estate == "prd-sam" || configs.kingdom == "xrd" || configs.kingdom == "phx" || configs.kingdom == "dfw" then true),
  enableMaddogCertChecks: (if samfeatureflags.maddogforsamapps && !utils.is_running_flannel(configs.kingdom) && !utils.is_pcn(configs.kingdom) then true else false),
  deleteSyntheticDeployment: false,
  filesystemCheckDirs: [
    "/data/",
    "/data/logs/sdn/",
    "/data/slb/logs/",
    "/home/sfdc/",
  ],
  filesystemRecursiveCheck: true,
  filesystemRecursiveCheckDirs: [
    "/data/",
    "/home/",
  ],

  # Maddog(cert) checker
  maddogCommonCerts: [
    "/etc/pki_service/kubernetes/k8s-server/certificates/k8s-server.pem",
    "/etc/pki_service/kubernetes/k8s-client/certificates/k8s-client.pem",
    "/etc/pki_service/etcd/etcd-client/certificates/etcd-client.pem",
    "/etc/pki_service/platform/platform-client/certificates/platform-client.pem",
    "/etc/pki_service/root/madkubtokenserver/certificates/madkubtokenserver.pem",
  ],
  cliCheckerFullCommands: {
    DockerDaemon: {
      DockerDaemon: "/test-docker.sh",
    },
  },
  maddogEtcdCerts: [
    "/etc/pki_service/etcd/etcd-server/certificates/etcd-server.pem",
    "/etc/pki_service/etcd/etcd-peer/certificates/etcd-peer.pem",
  ],

  #processUpTime checker
  universalProcesses: ["dockerd.*docker-bootstrap", "dockerd.*docker.sock", "docker-containerd.*docker-containerd.sock", "docker-containerd.*docker-bootstrap", "hyperkube.*kubelet"],
})

  #kubelet checker
  + (if configs.estate == "prd-samdev" || configs.estate == "prd-samtest" || configs.estate == "prd-sam" then {
     KubeletErrorCheckerEnabled: true,
     KubeletErrorPerSecond: 1,
     KubeletErrorCheckerFrequency: "20s",
    } else {})

  + (if configs.estate == "prd-sam" then {
     whiteListNamespaceRegexp: ["^[^.]+"],
     } else {})

  #Connectivitylabeler checker
  + {
    "node-endpoints": {
      madkub: "https://10.254.208.254:32007/healthz",
    },
    nodeUpdateWindow: "1h",
  }
