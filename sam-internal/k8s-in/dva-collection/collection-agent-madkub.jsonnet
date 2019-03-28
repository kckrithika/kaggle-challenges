{
    dirSuffix:: "",
    local configs = import "config.jsonnet",
    local utils = import "util_functions.jsonnet",
    local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile },
    local rsyslogimages = (import "collection-agent-images.jsonnet") + { dirSuffix:: $.dirSuffix },
    local rsyslogutils = (import "collection-agent-utils.jsonnet") + { dirSuffix:: $.dirSuffix },
    local maddogEndpoint = "https://10.168.195.227:8443",

    local certDirLookup = {
        cert1: {  // rsyslog-agent client certificate
            mount: {
                mountPath: "/cert1",
                name: "cert1",
            },
            volume: {
                emptyDir: {
                    medium: "Memory",
                },
                name: "cert1",
            },
            annotation: {
                name: "cert1",
                "cert-type": "client",
                kingdom: configs.kingdom,
                superpod: null,
                role: "rsyslog_agent",
                san: null,
            },
        },
        "client-certs": {
            mount: {
                mountPath: "/client-certs",
                name: "tls-client-cert",
            },
            volume: {
                emptyDir: {
                    medium: "Memory",
                },
                name: "tls-client-cert",
            },
            annotation: {
                name: "client-certs",
                kingdom: configs.kingdom,
                "cert-type": "client",
                superpod: null,
                role: "sam-system.cadvisor-exporter-daemonset",
                san: null,
            },
        },
        "server-certs": {
            mount: {
                mountPath: "/server-certs",
                name: "tls-server-cert",
            },
            volume: {
                emptyDir: {
                    medium: "Memory",
                },
                name: "tls-server-cert",
            },
            annotation: {
                name: "server-certs",
                kingdom: configs.kingdom,
                "cert-type": "server",
                superpod: null,
                role: "sam-system.cadvisor-exporter-daemonset",
                san: null,
            },
        },
    },

    madkubRsyslogCertFolders(certDirs):: [
      '--cert-folders=%s:/%s/' % [dir, dir]
        for dir in certDirs
    ],

    madkubRsyslogCertVolumeMounts(certDirs):: [
        certDirLookup[dir].mount
                for dir in certDirs
    ],

    madkubRsyslogCertVolumes(certDirs):: [
        certDirLookup[dir].volume
                for dir in certDirs
    ],

    madkubRsyslogCertsAnnotation(certDirs):: {
        certreqs: [
                certDirLookup[dir].annotation
                        for dir in certDirs
        ],
    },

    local madkubRsyslogMadkubVolumeMounts = [
        {
            mountPath: "/maddog-certs/",
            name: "maddog-certs",
        },
        {
            mountPath: "/tokens",
            name: "tokens",
        },
    ],

    madkubRsyslogMadkubVolumes():: [
        {
            emptyDir: {
                medium: "Memory",
            },
            name: "tokens",
        },
    ],

    madkubInitContainer(certDirs):: {
        image: if utils.is_pcn(configs.kingdom) then samimages.static.madkubPCN else samimages.madkub,
        args: [
            "/sam/madkub-client",
            "--madkub-endpoint=https://$(MADKUBSERVER_SERVICE_HOST):32007",
            "--maddog-endpoint=" + if utils.is_pcn(configs.kingdom) then configs.maddogGCPEndpoint else configs.maddogEndpoint + "",
            "--maddog-server-ca=/maddog-certs/ca/security-ca.pem",
            "--madkub-server-ca=/maddog-certs/ca/cacerts.pem",
        ] + $.madkubRsyslogCertFolders(certDirs) + [
            "--token-folder=/tokens/",
            "--ca-folder=/maddog-certs/ca",
        ],
        name: "madkub-init",
        imagePullPolicy: "IfNotPresent",
        volumeMounts: $.madkubRsyslogCertVolumeMounts(certDirs) + madkubRsyslogMadkubVolumeMounts,
        env: [
            {
                name: "MADKUB_NODENAME",
                valueFrom:
                    {
                        fieldRef: { fieldPath: "spec.nodeName", apiVersion: "v1" },
                    },
            },
            {
                name: "MADKUB_NAME",
                valueFrom:
                    {
                        fieldRef: { fieldPath: "metadata.name", apiVersion: "v1" },
                    },
            },
            {
                name: "MADKUB_NAMESPACE",
                valueFrom:
                    {
                        fieldRef: { fieldPath: "metadata.namespace", apiVersion: "v1" },
                    },
            },
        ],
    },

    madkubRefreshContainer(certDirs):: $.madkubInitContainer(certDirs) {
        args+: [
            "--refresher",
            "--run-init-for-refresher-mode",
        ],
        name: "madkub-refresher",
        resources: {},
    },

    permissionSetterInitContainer:: {
        command: [
            "bash",
            "-c",
            "set -ex\nchmod 775 -R /client-certs && chown -R 7447:7447 /client-certs\nchmod 775 -R /server-certs && chown -R 7447:7447 /server-certs\n",
        ],
        image: "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-gcp/dva/sam/hypersam:2601-1bbc5de4786678763a4e8a71681ee42ada887c76",
        imagePullPolicy: "IfNotPresent",
        name: "permissionsetterinitcontainer",
        securityContext: {
            runAsNonRoot: false,
            runAsUser: 0,
        },
        volumeMounts: [
          {
            # Server certs
            mountPath: "/client-certs",
            name: "tls-client-cert",
          },
          {
            # Client certs
            mountPath: "/server-certs",
            name: "tls-server-cert",
          },
        ],

    },
    # image_functions needs to know the filename of the template we are processing
    # Each template must set this at time of importing this file, for example:
    #
    # "local someteamimages = (import "someteamimages.jsonnet")  + { templateFilename:: std.thisFile };"
    #
    # Then we pass this again into image_functions at time of import.
    templateFilename:: error "templateFilename must be passed at time of import",
    local imageFunc = (import "image_functions.libsonnet") + { templateFilename:: $.templateFilename },
}
