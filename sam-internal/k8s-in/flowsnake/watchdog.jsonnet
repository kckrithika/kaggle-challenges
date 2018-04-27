local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local samconfig = import "config.jsonnet";
{
    watchdog_config: {
        "deployer-funnelEndpoint": flowsnakeconfig.funnel_vip_and_port,
        "deployer-imageName": flowsnakeimage.deployer,
        "deployer-rcImtEndpoint": samconfig.rcImtEndpoint,
        "deployer-recipient": "flowsnake@salesforce.com",
        "deployer-sender": "flowsnake@salesforce.com",
        "deployer-smtpServer": samconfig.smtpServer,
        deploymentNamespacePrefixWhitelist: "flowsnake",
        "email-subject-prefix": "FLOWSNAKEWD",
        enableMaddogCertChecks: true,
        enableStatefulChecks: true,
        enableStatefulPVChecks: true,
        funnelEndpoint: flowsnakeconfig.funnel_vip_and_port,
        imageName: flowsnakeimage.watchdog,
        kubeResourceNamespacePrefixBlacklist: "sam-watchdog",
        kubeResourceNamespacePrefixWhitelist: "sam-system,flowsnake",
        maxPVCAge: 420000000000,
        maxUptimeSampleSize: 5,
        maxdeploymentduration: 420000000000,
        monitoredProcesses: {
          "dockerd.*docker-bootstrap": "age.dockerbootstrap",
          "dockerd.*docker.sock": "age.dockermain",
          "hyperkube.*apiserver": "age.kubeapiserver",
          "hyperkube.*controller-manager": "age.kubecontrollermanager",
          "hyperkube.*kubelet": "age.kubelet",
          "hyperkube.*proxy": "age.kubeproxy",
          "hyperkube.*scheduler": "age.kubescheduler",
        },
        publishAlertsToKafka: false,
        publishAllReportsToKafka: false,
        rcImtEndpoint: samconfig.rcImtEndpoint,
        recipient: "flowsnake@salesforce.com",
        sdpEndpoint: "http://localhost:39999",
        sender: "flowsnake@salesforce.com",
        smtpServer: samconfig.smtpServer,
        syntheticPVRetrytimeout: 420000000000,
        syntheticretrytimeout: 420000000000,
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
    },
}
