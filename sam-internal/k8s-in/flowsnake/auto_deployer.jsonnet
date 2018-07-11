local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnake_sdn = import "flowsnake_sdn.jsonnet";
local samconfig = import "config.jsonnet";
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
{
    auto_deployer_enabled: !flowsnakeconfig.is_minikube,
    samcontroldeployer: {
        email: true,
        "email-delay": 0,
        "disable-rollback": true,
        "delete-orphans": false,
        "orphan-namespaces": "flowsnake,default,kube-system",
        "disable-security-check": true,
        "override-control-estate": "/" + kingdom + "/" + kingdom + "-sam",
        funnelEndpoint: flowsnakeconfig.funnel_vip_and_port,
        "max-resource-time": 300000000000,
        "poll-delay": 30000000000,
        recipient: "flowsnake@salesforce.com",
        "resource-cooldown": 15000000000,
        "resource-progression-timeout": 120000000000,
        sender: "flowsnake@salesforce.com",
        "smtp-server": samconfig.smtpServer,
        "tnrp-endpoint": samconfig.tnrpArchiveEndpoint,
        "ca-file": certs_and_kubeconfig.host_ca_cert_path,
        "cert-file": certs_and_kubeconfig.host_platform_client_cert_path,
        "key-file": certs_and_kubeconfig.host_platform_client_key_path,
        "dry-run": false,
        "resources-to-skip": [
            // always skip this, this is used for image promotion to prod.
            "image-promotion.yaml",
            // always skip this, should never get deployed by auto-deployer, sdn-secret-agent will read this file and deploy.
            "_flowsnake-sdn-secret.yaml",
        ] +
        (if !flowsnake_sdn.sdn_enabled then [
            "sdn-bird.yaml",
            "sdn-cleanup.yaml",
            "sdn-hairpin-setter.yaml",
            "sdn-peering-agent.yaml",
            "sdn-ping-watchdog.yaml",
            "sdn-route-watchdog.yaml",
            "sdn-secret-agent.yaml",
            "sdn-vault-agent.yaml",
        ] else if flowsnake_sdn.sdn_pre_deployment then [
            "cert-secretizer.yaml",
            "_zookeeper-rcs.yaml",
            "_zookeeper-set-svc.yaml",
            "flowsnake-api-ingress.yaml",
            "flowsnake-api-rc.yaml",
            "flowsnake-api-svc.yaml",
            "funnel-svc.yaml",
            "glok-rc.yaml",
            "glok-set-svc.yaml",
            "glok-svc.yaml",
            "ingress-controller-default-backend-svc.yaml",
            "ingress-controller-default-backend.yaml",
            "madkubserver-service.yaml",
            "madkubserver.yaml",
            "nginx-ingress-controller-rc.yaml",
            "nginx-ingress-controller-svc.yaml",
            "node-monitor-rc.yaml",
            "sdn-bird.yaml",
            "sdn-cleanup.yaml",
            "sdn-hairpin-setter.yaml",
            "sdn-peering-agent.yaml",
            "sdn-ping-watchdog.yaml",
            "sdn-route-watchdog.yaml",
            "sdn-secret.yaml",
            "sdn-vault-agent.yaml",
            "watchdog-common.yaml",
            "watchdog-etcd-quorum.yaml",
            "watchdog-etcd.yaml",
            "watchdog-master.yaml",
        ] else if flowsnake_sdn.sdn_during_deployment then [
        // this state will get maually edited during sdn rollout
        // after its done please reset it same as sdn_pre_deployment
            "cert-secretizer.yaml",
            "_zookeeper-rcs.yaml",
            "_zookeeper-set-svc.yaml",
            "flowsnake-api-ingress.yaml",
            "flowsnake-api-rc.yaml",
            "flowsnake-api-svc.yaml",
            "funnel-svc.yaml",
            "glok-rc.yaml",
            "glok-set-svc.yaml",
            "glok-svc.yaml",
            "ingress-controller-default-backend-svc.yaml",
            "ingress-controller-default-backend.yaml",
            "madkubserver-service.yaml",
            "madkubserver.yaml",
            "nginx-ingress-controller-rc.yaml",
            "nginx-ingress-controller-svc.yaml",
            "node-monitor-rc.yaml",
            "sdn-bird.yaml",
            "sdn-cleanup.yaml",
            "sdn-hairpin-setter.yaml",
            "sdn-peering-agent.yaml",
            "sdn-ping-watchdog.yaml",
            "sdn-route-watchdog.yaml",
            "sdn-secret.yaml",
            "sdn-vault-agent.yaml",
            "watchdog-common.yaml",
            "watchdog-etcd-quorum.yaml",
            "watchdog-etcd.yaml",
            "watchdog-master.yaml",
        ] else []) +
        (if flowsnakeconfig.deepsea_enabled then [
            // Must skip (and manually deploy) because AutoDeployer does not support Endpoints resources at the moment.
            // WI to change deepsea setup to not require the endpoint: https://gus.my.salesforce.com/a07B0000004lMMSIA2
            "deepsea-kdc-endpoints.yaml",
        ] else []),
    },
}
