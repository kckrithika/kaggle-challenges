local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local samconfig = import "config.jsonnet";
{
    auth_groups: (if std.objectHas(self.auth_groups_map, kingdom + "/" + estate) then $.auth_groups_map[kingdom + "/" + estate] else error "No matching auth_groups entry: " + kingdom + "/" + estate),
    auth_namespaces: (if std.objectHas(self.auth_namespaces_data, kingdom + "/" + estate) then $.auth_namespaces_data[kingdom + "/" + estate] else error "No matching auth_namespaces entry: " + kingdom + "/" + estate),
    // DEPRECATED: Used for deploying Flowsnake versions <= 0.9.6.
    // Map from fleet (kingdom/estate) to list of auth groups authorized to access it.
    auth_groups_map: {
        "prd/prd-data-flowsnake": [
            "Flowsnake_Ops_Platform",
            "Security-Analytics",
            "alerting_flowsnake",
            "dbvisibility",
            "IoT-RM-Flowsnake",
            "FS_Rackbot",
            "MCeventing",
            "Analytics Service Ownership",
            "CRE_AD",
            "Lightning_Instrumentation",
            "Analytics-DataPool",
            "DSS_FLOWSNAKE_SERVICE",
            "ServiceProtection",
            "collection_flowsnake",
            "key_infrastructure",
        ],
        "prd/prd-data-flowsnake_test": [
            "Flowsnake_Ops_Platform",
        ],
        "prd/prd-dev-flowsnake_iot_test": [
            "Flowsnake_Ops_Platform",
            "IoT-RM-Flowsnake",
            "CRE_AD",
            "Analytics-DataPool",
        ],
        "prd/prd-minikube-small-flowsnake": [
            "Flowsnake_Ops_Platform",
        ],
        "prd/prd-minikube-big-flowsnake": [
            "Flowsnake_Ops_Platform",
        ],
        "iad/iad-flowsnake_prod": [
        ],
        "ord/ord-flowsnake_prod": [
        ],
        "phx/phx-flowsnake_prod": [
        ],
    },

    // Map from fleet (kingdom/estate) to list of PKI namespaces and who is permitted to create Flowsnake environments
    // with that namespace in that fleet.
    // (Where "who" is identified by client certs for mTLS or LDAP group membership for Basic Auth)
    auth_namespaces_data: {
      "prd/prd-data-flowsnake": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: ["Flowsnake_Ops_Platform"],
            authorizedClientCerts: ["flowsnake_master"],
        },
        {
            namespace: "alerting_snmp",
            authorizedLdapGroups: ["alerting_flowsnake"],
            authorizedClientCerts: [],
        },
        {
            namespace: "sec-einstein-deepsea",
            authorizedLdapGroups: ["security-analytics"],
            authorizedClientCerts: [],
        },
      ],
      "prd/prd-data-flowsnake_test": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: ["Flowsnake_Ops_Platform"],
            authorizedClientCerts: ["flowsnake_master_test"],
        },
      ],
      "prd/prd-dev-flowsnake_iot_test": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: ["Flowsnake_Ops_Platform"],
            authorizedClientCerts: ["flowsnake_master_iot_test"],
        },
        {
            namespace: "retail-cre",
            authorizedLdapGroups: ["CRE_AD"],
            authorizedClientCerts: ["retail-cre.cre-control-plane-ccp-func", "retail-cre.cre-control-plane-ccp-perf", "retail-cre.cre-control-plane-ccp-dev"],
        },
        {
            namespace: "iot",
            authorizedLdapGroups: ["IoT-RM-Flowsnake"],
            authorizedClientCerts: ["iot.provisioning", "iot.provisioning-ftest", "iot.provisioning-provisioningtest"],
        },
        {
            namespace: "wave-elt",
            authorizedLdapGroups: ["Analytics-DataPool"],
            authorizedClientCerts: ["wave-elt.datapool", "wave-elt.datapool-test1", "wave-elt.datapool-test2", "wave-elt.datapool-steelthread"],
        },
      ],
      "prd/prd-minikube-small-flowsnake": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: ["Flowsnake_Ops_Platform"],
        },
        {
            namespace: "flowsnake_test",
            authorizedClientCerts: ["flowsnake.minikube"],
        },
      ],
      "prd/prd-minikube-big-flowsnake": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: ["Flowsnake_Ops_Platform"],
        },
        {
            namespace: "flowsnake_test",
            authorizedClientCerts: ["flowsnake.minikube"],
        },
      ],
      "iad/iad-flowsnake_prod": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["flowsnake_master_prod"],
        },
        {
            namespace: "retail-cre",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["retail-cre.cre-control-plane"],
        },
        {
            namespace: "wave-elt",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["wave-elt.datapool"],
        },
        {
            namespace: "iot",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["iot.provisioning"],
        },
      ],
      "ord/ord-flowsnake_prod": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["flowsnake_master_prod"],
        },
        {
            namespace: "retail-cre",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["retail-cre.cre-control-plane"],
        },
        {
            namespace: "wave-elt",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["wave-elt.datapool"],
        },
        {
            namespace: "iot",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["iot.provisioning"],
        },
      ],
      "phx/phx-flowsnake_prod": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["flowsnake_master_prod"],
        },
      ],
    },


    samcontroldeployer: {
        email: true,
        "email-delay": 0,
        "delete-orphans": false,
        "disable-rollback": true,
        "disable-security-check": true,
        "override-control-estate": "/" + kingdom + "/" + kingdom + "-sam",
        "orphan-namespaces": "flowsnake",
        funnelEndpoint: flowsnakeconfig.funnel_vip_and_port,
        "max-resource-time": 300000000000,
        "poll-delay": 30000000000,
        recipient: "flowsnake@salesforce.com",
        "resource-cooldown": 15000000000,
        "resource-progression-timeout": 120000000000,
        sender: "flowsnake@salesforce.com",
        "smtp-server": samconfig.smtpServer,
        "tnrp-endpoint": samconfig.tnrpArchiveEndpoint,
        "ca-file": flowsnakeconfig.host_ca_cert_path,
        "cert-file": flowsnakeconfig.host_platform_client_cert_path,
        "key-file": flowsnakeconfig.host_platform_client_key_path,
        "dry-run": false,
        "resources-to-skip": [
            // always skip this, this is used for image promotion to prod.
            "image-promotion.yaml",
            // always skip this, should never get deployed by auto-deployer, sdn-secret-agent will read this file and deploy.
            "_flowsnake-sdn-secret.yaml",
        ] +
        (if !flowsnakeconfig.sdn_enabled then [
            "sdn-bird.yaml",
            "sdn-cleanup.yaml",
            "sdn-hairpin-setter.yaml",
            "sdn-peering-agent.yaml",
            "sdn-ping-watchdog.yaml",
            "sdn-route-watchdog.yaml",
            "sdn-secret-agent.yaml",
            "sdn-vault-agent.yaml",
        ] else if flowsnakeconfig.sdn_pre_deployment then [
            "cert-secretizer.yaml",
            "_zookeeper-rcs.yaml",
            "_zookeeper-set-svc.yaml",
            "canary-ds.yaml",
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
        ] else if flowsnakeconfig.sdn_during_deployment then [
        // this state will get maually edited during sdn rollout
        // after its done please reset it same as sdn_pre_deployment
            "cert-secretizer.yaml",
            "_zookeeper-rcs.yaml",
            "_zookeeper-set-svc.yaml",
            "canary-ds.yaml",
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
    cert_secretizer_config: {
        certToSecretConfigs: [
            {
                type: "TLSSecret",
                secretName: "flowsnake-tls",
                certFileLocation: "/certs/server/certificates/server.pem",
                keyFileLocation: "/certs/server/keys/server-key.pem",
            },
            {
                type: "CASecret",
                secretName: "sfdc-ca",
                certFileLocation: "/certs/ca.pem",
            },
        ],
    },
}
