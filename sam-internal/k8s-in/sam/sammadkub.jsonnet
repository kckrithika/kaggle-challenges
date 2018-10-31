{
    dirSuffix:: "",
    local configs = import "config.jsonnet",
    local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile },

    // functions in this library take a certsDir paramter which is of the form (e.g.) ["cert1", "cert2"]
    // A parameter should pass an array of which cert classes it needs and based on that compute the volumes, volumeMounts, annotations, and maddog parameters

    local certDirLookup = {
        cert1: {  // client certificate
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
            },
        },
        cert2: {  // Sam internal certificate for SS
            mount: {
                mountPath: "/cert3",
                name: "cert3",
            },
            volume: {
                emptyDir: {
                    medium: "Memory",
                },
                name: "cert3",
            },
            annotation: {
                name: "cert3",
                "cert-type": "client",
                kingdom: configs.kingdom,
                role: "Sam.internal",
            },
        },
    },

    madkubSamCertFolders(certDirs):: [
      '--cert-folders=%s:/%s/' % [dir, dir]
        for dir in certDirs
    ],

    madkubSamCertVolumeMounts(certDirs):: [
        certDirLookup[dir].mount
                for dir in certDirs
    ],

    madkubSamCertVolumes(certDirs):: [
        certDirLookup[dir].volume
                for dir in certDirs
    ],

    madkubSamCertsAnnotation(certDirs):: {
        certreqs: [
                certDirLookup[dir].annotation
                        for dir in certDirs
        ],
    },

    local madkubSamMadkubVolumeMounts = [
        {
            mountPath: "/maddog-certs/",
            name: "maddog-certs",
        },
        {
            mountPath: "/tokens",
            name: "tokens",
        },
    ],

    madkubSamMadkubVolumes():: [
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
        ] + $.madkubSamCertFolders(certDirs) + [
            "--token-folder=/tokens/",
            "--requested-cert-type=client",
            "--ca-folder=/maddog-certs/ca",
        ],
        name: "madkub-init",
        imagePullPolicy: "IfNotPresent",
        volumeMounts: $.madkubSamCertVolumeMounts(certDirs) + madkubSamMadkubVolumeMounts,
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
        ] +
        if configs.estate == "prd-samtest" then [
            "--run-init-for-refresher-mode",
            "false",
        ] else [
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
