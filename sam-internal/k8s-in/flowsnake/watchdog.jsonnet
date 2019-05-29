local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnake_clichecker_commands = import "flowsnake_clichecker_commands.jsonnet";
local samconfig = import "config.jsonnet";
{
    watchdog_enabled: !(flowsnakeconfig.is_minikube),
    ## make sure add cliCheckerFullCommands
    watchdog_canary_versions:: ["0.11.0", "0.12.0", "0.12.1", "0.12.2", "0.12.5"],
    watchdog_email_frequency: if estate == "prd-data-flowsnake_test" then "72h" else "10m",
    watchdog_email_frequency_kuberesources: "72h",
    sfdchosts_volume: {
        configMap: {
          name: "sfdchosts",
        },
        name: "sfdchosts",
    },
    sfdchosts_volume_mount: {
        mountPath: "/sfdchosts",
        name: "sfdchosts",
    },
    watchdog_config: {
        cliCheckerFullCommands: flowsnake_clichecker_commands.command_sets,
        "deployer-funnelEndpoint": flowsnakeconfig.funnel_vip_and_port,
        "deployer-imageName": flowsnake_images.deployer,
        "deployer-rcImtEndpoint": samconfig.rcImtEndpoint,
        "deployer-recipient": "flowsnake@salesforce.com",
        "deployer-sender": "flowsnake@salesforce.com",
        "deployer-smtpServer": samconfig.smtpServer,
        "email-subject-prefix": "FLOWSNAKEWD",
        funnelEndpoint: flowsnakeconfig.funnel_vip_and_port,
        imageName: flowsnake_images.watchdog,
        kubeResourceNamespacePrefixBlacklist: "sam-watchdog",
        kubeResourceNamespacePrefixWhitelist: "sam-system,flowsnake" +
          if std.objectHas(flowsnake_images.feature_flags, "rm_kuberesources_cm") then ",kube-system" else "",
        maxUptimeSampleSize: 5,
        monitoredProcesses: {
          "docker-containerd.*docker-bootstrap": "age.dockercontainerdbootstrap",
          "docker-containerd.*docker-containerd.sock": "age.dockercontainerd",
          "dockerd.*docker-bootstrap": "age.dockerbootstrap",
          "dockerd.*docker.sock": "age.dockermain",
          "hyperkube.*apiserver": "age.kubeapiserver",
          "hyperkube.*controller-manager": "age.kubecontrollermanager",
          "hyperkube.*kubelet": "age.kubelet",
          "hyperkube.*proxy": "age.kubeproxy",
          "hyperkube.*scheduler": "age.kubescheduler",
          "name=etcd": "age.etcd",
        },
        publishAlertsToKafka: false,
        rcImtEndpoint: samconfig.rcImtEndpoint,
        recipient: "flowsnake@salesforce.com",
        sdpEndpoint: "http://localhost:39999",
        sender: "flowsnake@salesforce.com",
        smtpServer: samconfig.smtpServer,
        tlsEnabled: true,
        caFile: "/etc/pki_service/ca/cabundle.pem",
        certFile: "/etc/pki_service/platform/platform-client/certificates/platform-client.pem",
        keyFile: "/etc/pki_service/platform/platform-client/keys/platform-client-key.pem",
        # Snoozes - This is a central list of all snoozed watchdogs.  For each snooze, please add a comment explaining the reason
        # Format of struct is here: https://git.soma.salesforce.com/sam/sam/blob/master/pkg/tools/watchdog/internal/config/config.go
        # Fields `estates`, `checker`, and `until` are required.  Specific instances can be listed with `instances` or using regex with `instanceRegex`
        # Until date format is YYYY/MM/DD.
        #
        # Example: { estates: ["prd-samtest"], checker: "hairpinChecker", until: "2017/06/02" },
        snooze: [
          # snooze iad & ord due to un-fully deployed fleet.
          { estates: ["iad-flowsnake_prod"], checker: "kubeletChecker", until: "2018/04/30" },
          { estates: ["ord-flowsnake_prod"], checker: "kubeletChecker", until: "2018/04/30" },
          { estates: ["iad-flowsnake_prod"], checker: "nodeChecker", until: "2018/04/30" },
          { estates: ["ord-flowsnake_prod"], checker: "nodeChecker", until: "2018/04/30" },
          { estates: ["iad-flowsnake_prod"], checker: "podChecker", until: "2018/04/30" },
          { estates: ["ord-flowsnake_prod"], checker: "podChecker", until: "2018/04/30" },
          { estates: ["iad-flowsnake_prod"], checker: "kubeResourcesChecker", until: "2018/04/30" },
          { estates: ["ord-flowsnake_prod"], checker: "kubeResourcesChecker", until: "2018/04/30" },
        ],
        universalProcesses: [
          "dockerd.*docker-bootstrap",
          "dockerd.*docker.sock",
          "hyperkube.*kubelet",
          "docker-containerd.*docker-containerd.sock",
          "docker-containerd.*docker-bootstrap",
        ],
    },
}
