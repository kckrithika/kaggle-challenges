local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local flowsnake_sdn = import "flowsnake_sdn.jsonnet";
local samconfig = import "config.jsonnet";
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";

local all_resources = [
    "__flowsnake-ns.yaml",
    "_fleet-config-default.yaml",
    "_fleet-config.yaml",
    "_flowsnake-sdn-secret.yaml",
    "_sfdchosts-configmap-sam.yaml",
    "_sfdchosts-configmap.yaml",
    "_topic-grants-cm.yaml",
    "_version-mapping.yaml",
    "_watchdog-configmap.yaml",
    "_zookeeper-rcs.yaml",
    "_zookeeper-set-svc.yaml",
    "ajna-applog-logrecordtype-grants-configmap.yaml",
    "ajna-applog-logrecordtype-whitelist-configmap.yaml",
    "auth-groups-configmap.yaml",
    "auth-namespaces-configmap.yaml",
    "cert-secretizer.yaml",
    "certs-to-secrets.yaml",
    "check-btrfs-sh-configmap.yaml",
    "client_namespaces.yaml",
    "flowsnake-api-ingress.yaml",
    "flowsnake-api-rc.yaml",
    "flowsnake-api-svc.yaml",
    "flowsnake-event-exporter.yaml",
    "flowsnake_rbac_client_auth.yaml",
    "flowsnake_rbac_host_admin.yaml",
    "flowsnake_sa_autodeployer.yaml",
    "flowsnake_sa_impersonator.yaml",
    "funnel-svc.yaml",
    "glok-rc.yaml",
    "glok-set-svc.yaml",
    "glok-svc.yaml",
    "image-promotion.yaml",
    "impersonation-proxy-svc.yaml",
    "impersonation-proxy.yaml",
    "ingress-controller-default-backend-svc.yaml",
    "ingress-controller-default-backend.yaml",
    "integration-test-data-rc.yaml",
    "integration-test-data-svc.yaml",
    "kubedns.yaml",
    "kubesvc.yaml",
    "madkub-container-configmap.yaml",
    "madkub-injector-auth-configuration.yaml",
    "madkub-injector-deployment.yaml",
    "madkub-injector-service.yaml",
    "madkub-injector-webhook-config.yaml",
    "madkub-required-volumes.yaml",
    "madkubserver-service.yaml",
    "madkubserver.yaml",
    "nginx-ingress-controller-rc.yaml",
    "nginx-ingress-controller-svc.yaml",
    "node-controller.yaml",
    "prometheus-funnel-configmap.yaml",
    "prometheus-funnel.yaml",
    "prometheus-funnel_sa.yaml",
    "samcontrol-deployer-configmap.yaml",
    "samcontrol-deployer.yaml",
    "sdn-bird.yaml",
    "sdn-cleanup.yaml",
    "sdn-hairpin-setter.yaml",
    "sdn-peering-agent.yaml",
    "sdn-ping-watchdog.yaml",
    "sdn-route-watchdog.yaml",
    "sdn-secret-agent.yaml",
    "sdn-vault-agent.yaml",
    "snapshoter-configmap.yaml",
    "snapshoter.yaml",
    "spark-operator-deployment.yaml",
    "spark-operator-rbac.yaml",
    "synthetic-dns-check-configmap.yaml",
    "synthetic-dns-check-deployment.yaml",
    "watchdog-canary-0-11-0.yaml",
    "watchdog-canary-0-12-0.yaml",
    "watchdog-canary-0-12-1.yaml",
    "watchdog-canary-0-12-2.yaml",
    "watchdog-canary-list.yaml",
    "watchdog-btrfs.yaml",
    "watchdog-common.yaml",
    "watchdog-docker-daemon.yaml",
    "watchdog-etcd-quorum.yaml",
    "watchdog-etcd.yaml",
    "watchdog-master.yaml",
    "deepsea-kdc-endpoints.yaml",
    "deepsea-kdc-svc.yaml",

];

local skip_resources = std.uniq(std.sort(
    [
        // always skip this, this is used for image promotion to prod.
        "image-promotion.yaml",
        // always skip this, should never get deployed by auto-deployer, sdn-secret-agent will read this file and deploy.
        "_flowsnake-sdn-secret.yaml",
        "sdn-secret.yaml",
    ] +
    (if flowsnakeconfig.deepsea_enabled then [
        // Must skip (and manually deploy) because AutoDeployer does not support Endpoints resources at the moment.
        // WI to change deepsea setup to not require the endpoint: https://gus.my.salesforce.com/a07B0000004lMMSIA2
        "deepsea-kdc-endpoints.yaml",
    ] else []) +
    // If bootstrap resources are defined because the estate is process of
    // being set up, permit only those. Otherwise allow all.
    (if std.length(flowsnake_sdn.bootstrap_resources) > 0
      then std.setDiff(std.sort(all_resources), std.sort(flowsnake_sdn.bootstrap_resources))
      else [])
));

local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };

{
    auto_deployer_enabled: !flowsnakeconfig.is_minikube,
    samcontroldeployer: {
        email: true,
        "email-delay": 0,
        "disable-rollback": true,
        // v1 generates environment service dynamically out of manifest; disable orphan deletion when v1 is enabled
        "delete-orphans": !flowsnakeconfig.is_v1_enabled,
        "orphan-namespaces": (if flowsnakeconfig.is_v1_enabled then "flowsnake,default,kube-system" else "flowsnake,sam-system"),
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
        "resources-to-skip": skip_resources,
    },
}
