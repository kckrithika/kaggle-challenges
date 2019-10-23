{
    dirSuffix:: "",
    local configs = import "config.jsonnet",
    local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile },
    local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbimages = (import "slbimages.jsonnet") + { dirSuffix:: $.dirSuffix },
    local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: $.dirSuffix },

    // functions in this library take a certsDir paramter which is of the form (e.g.) ["cert1", "cert2"]
    // A parameter should pass an array of which cert classes it needs and based on that compute the volumes, volumeMounts, annotations, and maddog parameters

    local steamVipSans = [
        "*.stmda.stm.salesforce.com",
        "*.my.stmda.stm.salesforce.com",
        "*.eu2.stmda.stm.force.com",
        "*.stmda.stm.force.com",
        "*.eu2.visual.stmda.stm.force.com",
        "*.eu2.content.stmda.stm.force.com",
        "*.stmda.stm.cloudforce.com",
        "*.stmda.stm.database.com",
        "*.builder.stmda.stm.salesforce-communities.com",
        "*.preview.stmda.stm.salesforce-communities.com",
        "*.livepreview.stmda.stm.salesforce-communities.com",
        "*.dop.sfdc.net",
        "*.stmda.stm.documentforce.com",
        "*.stmda.stm.visualforce.com",
        "*.lightning.stmda.stm.force.com",
        "*.container.stmda.stm.lightning.com",
        "services.stmda.stm.salesforce.com",
        "cloudatlas.stmda.stm.salesforce.com",
        "*.a.stmda.stm.forceusercontent.com",
        "*.d.stmda.stm.forceusercontent.com",
    ],

    local serverCert(name) = {
        mount: {
            mountPath: "/" + name,
            name: name,
        },
        volume: {
            emptyDir: {
                medium: "Memory",
            },
            name: name,
        },
        annotation: {
            name: name,
            "cert-type": "server",
            kingdom: configs.kingdom,
            role: slbconfigs.samrole,
            san: [
                "*.sam-system." + configs.estate + "." + configs.kingdom + ".slb.sfdc.net",
                "*.slb.sfdc.net",
                "*.soma.salesforce.com",
                "*.data.sfdc.net",
                "*.kms.slb.sfdc.net",
                "*.moe." + configs.estate + "." + configs.kingdom + ".slb.sfdc.net",
                "*.internal.salesforce.com",
            ] + (if configs.estate == "prd-sam" || configs.estate == "prd-samtwo" then (steamVipSans + [
                "*.retail-rsui." + configs.estate + "." + configs.kingdom + ".slb.sfdc.net",
                "*.stmfa.stm.salesforce-hub.com",
                "*.my.stmfa.stm.salesforce-hub.com",
                "*.my.stmfb.stm.salesforce-hub.com",
                "*.my.mist60.stm.salesforce-hub.com",
            ]) else []),
        },
    },

    local clientCert(name) = {
        mount: {
            mountPath: "/" + name,
            name: name,
        },
        volume: {
            emptyDir: {
                medium: "Memory",
            },
            name: name,
        },
        annotation: {
            name: name,
            "cert-type": "client",
            kingdom: configs.kingdom,
            role: slbconfigs.samrole,
        },
    },

    // slb internal certificate, used as a client cert for mTLS sessions that
    // are not originated by customer traffic (e.g., talking to secret service
    // or vault or your best friend).
    local slbInternalCertificate(name) = {
        mount: {
            mountPath: "/" + name,
            name: name,
        },
        volume: {
            emptyDir: {
                medium: "Memory",
            },
            name: name,
        },
        annotation: {
            name: name,
            "cert-type": "client",
            kingdom: configs.kingdom,
            role: "slb.internal",
        },
    },

    local certDirLookup = {
        cert1: serverCert("cert1"),
        "server-certs": serverCert("server-certs"),

        cert2: clientCert("cert2"),
        "client-certs": clientCert("client-certs"),

        // slb internal certificate for SS
        cert3: slbInternalCertificate("cert3"),

        canarycert: {  // certificate for canaries setting up https ports
            mount: {
                mountPath: "/canarycert",
                name: "canarycert",
            },
            volume: {
                emptyDir: {
                    medium: "Memory",
                },
                name: "canarycert",
            },
            annotation: {
                name: "canarycert",
                "cert-type": "server",
                kingdom: configs.kingdom,
                role: "slb.canary",
            },
        },
    },

    madkubSlbCertFolders(certDirs):: [
      '--cert-folders=%s:/%s/' % [dir, dir]
        for dir in certDirs
    ],

    madkubSlbCertVolumeMounts(certDirs):: [
        certDirLookup[dir].mount
                for dir in certDirs
    ],

    madkubSlbCertVolumes(certDirs):: [
        certDirLookup[dir].volume
                for dir in certDirs
    ],

    madkubSlbCertsAnnotation(certDirs):: {
        certreqs: [
                certDirLookup[dir].annotation
                        for dir in certDirs
        ],
    },

    local madkubSlbMadkubVolumeMounts = [
        {
            mountPath: "/maddog-certs/",
            name: "maddog-certs",
        },
        {
            mountPath: "/tokens",
            name: "tokens",
        },
    ],

    madkubSlbMadkubVolumes():: [
        {
            emptyDir: {
                medium: "Memory",
            },
            name: "tokens",
        },
    ],

    madkubInitContainer(certDirs):: {
        image: "" + samimages.madkub + "",
        args: [
            "/sam/madkub-client",
            "--madkub-endpoint=https://$(MADKUBSERVER_SERVICE_HOST):32007",
            "--maddog-endpoint=" + configs.maddogEndpoint + "",
            "--maddog-server-ca=/maddog-certs/ca/security-ca.pem",
            "--madkub-server-ca=/maddog-certs/ca/cacerts.pem",
        ] + $.madkubSlbCertFolders(certDirs) + [
            "--token-folder=/tokens/",
            "--requested-cert-type=client",
            "--ca-folder=/maddog-certs/ca",
        ],
        name: "madkub-init",
        imagePullPolicy: "IfNotPresent",
        volumeMounts: $.madkubSlbCertVolumeMounts(certDirs) + madkubSlbMadkubVolumeMounts,
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

    # image_functions needs to know the filename of the template we are processing
    # Each template must set this at time of importing this file, for example:
    #
    # "local someteamimages = (import "someteamimages.jsonnet")  + { templateFilename:: std.thisFile };"
    #
    # Then we pass this again into image_functions at time of import.
    templateFilename:: error "templateFilename must be passed at time of import",
    local imageFunc = (import "image_functions.libsonnet") + { templateFilename:: $.templateFilename },
}
