#
# NOTE: This file should contain the minimum set of shared data needed by the different teams (SAM, SLB, SDN, etc...)
# Do not put team-specific configuration here.  We should keep this file as small as possible.
#
{
local estate = std.extVar("estate"),
local kingdom = std.extVar("kingdom"),
local engOrOps = (if self.kingdom == "prd" || self.kingdom == "xrd" then "eng" else "ops"),

local utils = import "util_functions.jsonnet",

    # === DISCOVERY ===

    # External services we need to talk to that are different in different kingdoms

    perKingdom: {

        # We should try and compute kingdom level config and not require an entry per kingdom!

        # Why are some of these 1-4, some 2-2, some 1-2, and others 2-1???
        # TODO: Clean this up
        smtpServer: {
            prd: "smtpops-prd-sp1.data.sfdc.net:25",
            xrd: "ops0-mta2-2-xrd.ops.sfdc.net:25",  #not sure if should match prod or prd
            dfw: "ops0-mta2-2-dfw.ops.sfdc.net:25",
            phx: "ops0-mta1-2-phx.ops.sfdc.net:25",
            frf: "ops0-mta2-1-frf.ops.sfdc.net:25",
            par: "ops0-mta2-1-par.ops.sfdc.net:25",
            yul: "ops0-mta2-1-yul.ops.sfdc.net:25",
            yhu: "ops0-mta2-1-yhu.ops.sfdc.net:25",
            iad: "ops0-mta2-1-iad.ops.sfdc.net:25",
            ord: "ops0-mta2-1-ord.ops.sfdc.net:25",
            ukb: "ops0-mta2-1-ukb.ops.sfdc.net:25",
            hnd: "ops0-mta2-1-hnd.ops.sfdc.net:25",
            cdu: "ops0-mta2-1-cdu.ops.sfdc.net:25",
            syd: "ops0-mta2-1-syd.ops.sfdc.net:25",
            chx: "ops-mta1-4-chx.ops.sfdc.net:25",
            wax: "ops-mta1-4-wax.ops.sfdc.net:25",
            cdg: "ops0-mta2-1-cdg.ops.sfdc.net:25",
            fra: "ops0-mta2-1-fra.ops.sfdc.net:25",
            vpod: "rd1-mta1-3-sfm.ops.sfdc.net:25",
            ia2: "ops0-mta2-1-ia2.ops.sfdc.net:25",
            ph2: "ops0-mta2-1-ph2.ops.sfdc.net:25",
            lo2: "ops0-mta2-1-lo2.ops.sfdc.net:25",
            lo3: "ops0-mta2-1-lo3.ops.sfdc.net:25",
            hio: "ops0-mta1-4-hio.ops.sfdc.net:25",
            ttd: "ops0-mta1-4-ttd.ops.sfdc.net:25",
            ia4: "ops0-mta2-1-ia4.ops.sfdc.net:25",
            ia5: "ops0-mta2-1-ia5.ops.sfdc.net:25",
        },

        # TODO: remove mom and charon endpoint to sdn-config
        charonEndpoint: {
            prd: "http://sds2-polcore2-2-prd.eng.sfdc.net:9443/minions",
        },

            zookeeperip: {
                prd: "shared0-discovery1-0-sfm.data.sfdc.net:2181",
            },

    },

    # Pass-through for the kingdom specific stuff above

    smtpServer: (if utils.is_pcn(kingdom) then "fakeSmtpServer" else self.perKingdom.smtpServer[kingdom]),
    momCollectorEndpoint: self.perKingdom.momCollectorEndpoint[kingdom],
    charonEndpoint: self.perKingdom.charonEndpoint[kingdom],
    zookeeperip: self.perKingdom.zookeeperip[kingdom],

    # Other discovery related things

    funnelVIP: (
    if kingdom == "par" || kingdom == "frf" then
        "mandm-funnel-" + kingdom + "1.data.sfdc.net:8080"
    else if kingdom == "chx" || kingdom == "wax" then
        "mandm-funnel-" + kingdom + ".data.sfdc.net:8080"
    else if utils.is_pcn(kingdom) then
        "funnel.ajnalocal1.vip.core.test.us-central1.gcp.sfdc.net:443"
    else
        "ajna0-funnel1-0-" + kingdom + ".data.sfdc.net:80"
    ),
    # [mayank]
    # This is the Tnrp EndPoint VIP without the complete path
    # We should migrate all our services to use this Endpoint.
    # The Individual services can append paths to it to make
    # appropriate urls. The tnrpArchiveEndPoint should be
    # deprecated in favor of this.
    tnrpEndpoint: (
    # Rolling to use LB endpoints (.data)
    # [thargrove] TNRP has bad servers in par and prd, so pinning them to the good server
    # until we roll a code fix
    if utils.is_public_cloud(kingdom) then
        "https://ops0-piperepo1-1-" + kingdom + "." + engOrOps + ".sfdc.net/"
    else if kingdom == "chx" || kingdom == "wax" then
        "https://ops-piperepo1-0-" + kingdom + ".data.sfdc.net/"
    else
        "https://ops0-piperepo1-0-" + kingdom + ".data.sfdc.net/"
    ),
    tnrpArchiveEndpoint: (
    if utils.is_pcn(kingdom) then
        "https://ops0-artifactrepo2-0-xrd.slb.sfdc.net/tnrp/content_repo/0/archive"
    else
        self.tnrpEndpoint + "tnrp/content_repo/0/archive"
    ),
    registry: (
    if kingdom == "prd" then
        "ops0-artifactrepo2-0-" + kingdom + ".data.sfdc.net"
    else if kingdom == "wax" || kingdom == "chx" then
        "ops-artifactrepo1-0-" + kingdom + ".data.sfdc.net"
    else if kingdom == "vpod" then
        #use PRD
        "ops0-artifactrepo2-0-prd.data.sfdc.net"
    else if kingdom == "mvp" then
        "ops0-artifactrepo2-0-xrd.slb.sfdc.net"
    else if utils.is_aws(kingdom) then
        "791719295754.dkr.ecr.us-east-2.amazonaws.com"
    else
        "ops0-artifactrepo1-0-" + kingdom + ".data.sfdc.net"
    ),
    rcImtEndpoint: (if kingdom == "dfw" then "http://shared0-samminionreportcollector1-1-dfw.ops.sfdc.net:18443/v1/bark" else "https://reportcollector-" + kingdom + ".data.sfdc.net:18443/v1/bark"),
    maddogEndpoint: "https://all.pkicontroller.pki.blank." + kingdom + ".prod.non-estates.sfdcsd.net:8443",
    maddogGCPEndpoint: "https://10.168.192.190:8443",

    # setting label name to identify which team owns the app
    ownerLabel: {
        sam: {
            "sam.data.sfdc.net/owner": "sam",
        },
        sdn: {
            "sam.data.sfdc.net/owner": "sdn",
        },
        slb: (
            if estate == "prd-samdev" || estate == "prd-samtest" || estate == "prd-sam" || estate == "cdu-sam" then {
                "sam.data.sfdc.net/owner": "slb",
            } else {}
        ),
        tnrp: {
            "sam.data.sfdc.net/owner": "tnrp",
        },
        secrets: {
            "sam.data.sfdc.net/owner": "secrets",
        },
    },

    # === KUBERNETES PARTIAL STRUCTS ===

    # Apps that use kubernetesApi need the config and env var.  This adds MadDog automatically
    # Use this like this example below.  Ensure that volumeMounts, volume and env have the '+' before ':'!
    #
    # spec: {
    #   template: {
    #     spec: configs.specWithKubeConfigAndMadDog {
    #       containers: [
    #         configs.containerWithKubeConfigAndMadDog {
    #           volumeMounts+: [ ... ],
    #           env+: [ ... ],
    #         }
    #       ],
    #       volumes+: [ ... ]
    #    }
    #  }
    containerWithKubeConfigAndMadDog: $.containerWithMadDog {
        [if !utils.is_pcn(kingdom) then "volumeMounts"]+: [$.kube_config_volume_mount],
        [if !utils.is_pcn(kingdom) then "env"]+: [$.kube_config_env],
    },
    specWithKubeConfigAndMadDog: $.specWithMadDog {
        [if !utils.is_pcn(kingdom) then "volumes"]+: [$.kube_config_volume],
    },

    # Adds MadDog.  Use the same way you would use KubeConfig above
    containerWithMadDog: {
        [if !utils.is_pcn(kingdom) then "volumeMounts"]+: [$.maddog_cert_volume_mount],
    },
    specWithMadDog: {
        [if !utils.is_pcn(kingdom) then "volumes"]+: [$.maddog_cert_volume],
    },

    # TODO: We should probably phase these out.
    containerWithCertServices: {
        volumeMounts+: [$.cert_volume_mount],
    },
    specWithCertServices: {
        volumes+: [$.cert_volume],
    },

    # Use this for every pod that is not on host network.
    # Add it in one of the containers of the template.
    # Example usage:
    # containers: [
    #      {
    #      name: "foo",
    #        resources:
    #          {
    #            limits+: { cpu: 10 }
    #          } + ipAddressResource,
    #      },
    #    ],
    ipAddressResource: {
      limits+: {
        "sam.sfdc.net/ip-address": "1",
      },
      requests+: {
        "sam.sfdc.net/ip-address": "1",
      },
    },

    # The set of estates for which non-host network pods should have a container requesting
    # an ip-address resource.
    ipAddressResourceRequestEnabledEstates: std.set([
        "prd-sam",
        "prd-samdev",
        "prd-samtest",
        "prd-sdc",
    ]),

    # For estates where ip-address resource requests are enabled, this mixin augments a container's
    # "resources" field to include an ip-address resource request.
    ipAddressResourceRequest: {
        [if std.setMember(estate, $.ipAddressResourceRequestEnabledEstates) then "resources"]+: $.ipAddressResource,
    },

    # The default maximum number of pod IP addresses a node is capable of supporting. This is used
    # by node-controller when there's an error reading from the --sdn-subnet-file-path file.
    # In PRD we really have 29, but setting it to 28 incase we have a pod missing the request.  With a setting of 29
    # any mis-labeled pod will cause issues.  This gives us a tiny bit of buffer.
    defaultMaxPodIP: (if estate == "prd-sdc" then 13 else 28),

    # This base contains common deployment fields to cut down on copy paste.
    # Use it like this (dont forget the '+' after spec):
    #
    # configs.deploymentBase("sam") {
    #   spec+: {
    #     template: { ... }
    #   }
    # }
    #
    # TODO: Once we switch to v1 from v1beta, we can add labels+ownerLabel.  Maybe over time we can also compute name.
    deploymentBase(owner):: {
      # Here we make a copy of the pointer to this outer object for use in children
      # We do this so child elements can reference it.  This is ugly, but all the alternatives dont work for one reason or another:
      #  1) 'self' points to the child
      #  2) '$' points to the root of this included file, but $.deploymentBase is not the same as the instance we are creating
      #  3) 'super' would work for the code derived from this, but this has no base
      #  4) There is no 'parent' keyword, which would be super handy
      local depl = self,
      kind: "Deployment",
      apiVersion: "extensions/v1beta1",
      spec+: {
        selector: {
          matchLabels: depl.spec.template.metadata.labels,
        },
        [if owner == "sam" then "template"]+: {
          metadata+: {
            labels+: {
              "sam.data.sfdc.net/owner": owner,
            },
          },
        },
      },
    },

    # This base contains common DaemonSet fields to cut down on copy paste.
    # Use it like this (dont forget the '+' after spec):
    #
    # configs.daemonSetBase("sam") {
    #   spec+: {
    #     template: { ... }
    #   }
    # }
    #
    # TODO: Once we switch to v1 from v1beta, we can add labels+ownerLabel.  Maybe over time we can also compute name.
    daemonSetBase(owner): {
      # Here we make a copy of the pointer to this outer object for use in children
      # We do this so child elements can reference it.  This is ugly, but all the alternatives dont work for one reason or another:
      #  1) 'self' points to the child
      #  2) '$' points to the root of this included file, but $.daemonSetBase is not the same as the instance we are creating
      #  3) 'super' would work for the code derived from this, but this has no base
      #  4) There is no 'parent' keyword, which would be super handy
      local ds = self,
      kind: "DaemonSet",
      apiVersion: "extensions/v1beta1",
      spec+: {
        selector: {
          matchLabels: ds.spec.template.metadata.labels,
        },
        [if owner == "sam" then "template"]+: {
          metadata+: {
            labels+: {
                "sam.data.sfdc.net/owner": owner,
            },
          },
        },
      },

    },


    # === KUBERNETES ===

    # For things like volumes, volume_mounts and args, we want to be able to define a new entry centrally (config.jsonnet)
    # but to roll it out gradually.  Since each template has a list for these items, we have 2 bad options:
    #  1) Add an if statement for each template (several dozen)
    #  2) Add the items and a second list that conditionally contains those items centrally, then add them in the templates
    # by using this helper function, the central config can define an item that is {} when not in use, and this will remove it from output list
    filter_empty(in_list):: [i for i in in_list if i != {}],

    # Commonly used elements for kubernetes resources

    # For use by apps that talk to the Kube API server using the host's kubeConfig
    kube_config_env: {
        name: "KUBECONFIG",
        value: "/kubeconfig/kubeconfig-platform",
    },
    kube_config_volume_mount: {
        mountPath: "/kubeconfig",
        name: "kubeconfig",
    },
    kube_config_volume: {
        hostPath: {
            path: "/etc/kubernetes",
        },
        name: "kubeconfig",
    },

    # For Cleaning up SLB logs or other Random mounts to be used for ops-adhoc DaemonSet
    opsadhoc_volume_mount: {
        mountPath: "/slb",
        name: "slblogs",
    },
    opsadhoc_volume: {
        hostPath: {
            path: "/var/slb/logs",
        },
        name: "slblogs",
    },

    # For use by apps that read the host's certs from Certificate Services
    cert_volume_mount: (if !utils.is_pcn(kingdom) then {
        mountPath: "/data/certs",
        name: "certs",
    } else {}),
    cert_volume: (if !utils.is_pcn(kingdom) then {
        hostPath: {
            path: "/data/certs",
        },
        name: "certs",
    } else {}),
    caFile: (
        "/etc/pki_service/ca/cabundle.pem"
    ),
    caCertsFile: (
        "/etc/pki_service/ca/cacerts.pem"
    ),
keyFile: (
        "/etc/pki_service/platform/platform-client/keys/platform-client-key.pem"
    ),
    certFile: (
        "/etc/pki_service/platform/platform-client/certificates/platform-client.pem"
    ),
    chainFile: (
        if kingdom == "prd" || kingdom == "xrd" then
            "/etc/pki_service/kubernetes/chain-client.pem"
        else
            "/etc/certs/hostcert-chain.pem"
    ),
    maddogServerCAPath: "/etc/pki_service/ca/security-ca.pem",

    # For apps that read MadDog certs from the host
    maddog_cert_volume_mount: {
        mountPath: "/etc/pki_service",
        name: "maddog-certs",
    },
    maddog_cert_volume: {
        hostPath: {
            path: "/etc/pki_service",
        },
        name: "maddog-certs",
    },

    # For apps that needs var tmp directory from the host
    var_tmp_volume_mount: {
        mountPath: "/var/tmp",
        name: "var-tmp",
    },
    var_tmp_volume: {
        hostPath: {
            path: "/var/tmp",
        },
        name: "var-tmp",
    },

    # For use by PCN sfdclocation
    pcn_kingdom_env: {
        name: "SFDCLOC_PCN_KINGDOM",
        value: kingdom,
    },

    pcn_estate_env: {
        name: "SFDCLOC_PCN_ESTATE",
        value: estate,
    },

    pcn_kube_config_env: {
        name: "KUBECONFIG",
        value: "",
    },

    containerInPCN: (if utils.is_pcn(kingdom) then {
        env: [
            $.pcn_kingdom_env,
            $.pcn_estate_env,
            $.pcn_kube_config_env,
        ],
    } else {}),

    serviceAccount: (if utils.is_pcn(kingdom) then {
         serviceAccount: "sam-stack-edit",
         serviceAccountName: "sam-stack-edit",

    } else {}),

    nodeSelector: (if !utils.is_aws(kingdom) then {
         nodeSelector: {} +
         if !utils.is_production(kingdom) then {
             master: "true",
         } else {
             pool: estate,
         },
    } else {}),

    pcnEnableLabel: (if utils.is_pcn(kingdom) && (kingdom != "aws-us-west-2") then {
        pcn: "deploy",
    } else {}),

    # For apps that use liveConfig + configMap for configuration
    config_volume_mount: {
        mountPath: "/config",
        name: "config",
    },
    watchdog_volume_mount: {
        mountPath: "/config",
        name: "watchdogconfig",
    },
    config_volume(configMap):: {
        name: "config",
        configMap: {
            name: configMap,
        },
    },

    # For apps that use sfdcLocation2
    sfdchosts_volume_mount: (if !utils.is_pcn(kingdom) then {
        mountPath: "/sfdchosts",
        name: "sfdchosts",
    } else {}),

    sfdchosts_volume: (if !utils.is_pcn(kingdom) then {
        name: "sfdchosts",
        configMap: {
            name: "sfdchosts",
        },
    } else {}),

    sfdchosts_arg: "--hostsConfigFile=/sfdchosts/hosts.json",

    # For apps that uses ci-namespace configmap
    ci_namespaces_volume_mount: {
        mountPath: "/ci",
        name: "ci-namespaces",
    },
    ci_namespaces_volume: {
        name: "ci-namespaces",
        configMap: {
            name: "ci-namespaces",
        },
    },
    dnsdomain: (
if utils.is_pcn(kingdom) then
            std.split(estate, "-")[4] + ".core.test.us-central1.gcp.sfdc.net"
        else
            estate + "." + kingdom + ".sam.sfdc.net"
    ),

    # === OTHER ===

    # These are here so files that include this jsonnet can easily access estate/kingdom.
    # Please dont add any more here.  We want to reduce coupling to this global config.

    estate: estate,
    kingdom: kingdom,
}
