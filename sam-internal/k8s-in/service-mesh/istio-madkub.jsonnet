{
  local configs = import "config.jsonnet",
  local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile },

  // Functions in this library take a certsDir paramter which is of the form (e.g.) ["cert1", "cert2"]
  // A parameter should pass an array of which cert classes it needs and based on that compute the volumes, volumeMounts, annotations, and maddog parameters

  local istioSans = [
    "istio-sidecar-injector",
    "istio-sidecar-injector.mesh-control-plane",
    "istio-sidecar-injector.mesh-control-plane.svc",  // This is the one that works with webhook's clientConfig.service
    "istio-sidecar-injector.mesh-control-plane.svc.%s" % configs.dnsdomain,
  ],

  local certRole = "istio.mesh-control-plane",

  local certDirLookup = {
    cert1: {  // server certificate
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
        "cert-type": "server",
        kingdom: configs.kingdom,
        role: certRole,
        san: istioSans,
      },
    },
    cert2: {  // client certificate
      mount: {
        mountPath: "/cert2",
        name: "cert2",
      },
      volume: {
        emptyDir: {
          medium: "Memory",
        },
        name: "cert2",
      },
      annotation: {
        name: "cert2",
        "cert-type": "client",
        kingdom: configs.kingdom,
        role: certRole,
      },
    },
  },

  madkubIstioCertFolders(certDirs):: [
    '--cert-folders=%s:/%s/' % [dir, dir]
    for dir in certDirs
  ],

  madkubIstioCertVolumeMounts(certDirs):: [
    certDirLookup[dir].mount
        for dir in certDirs
  ],

  madkubIstioCertVolumes(certDirs):: [
    certDirLookup[dir].volume
        for dir in certDirs
  ],

  madkubIstioCertsAnnotation(certDirs):: {
    certreqs: [
        certDirLookup[dir].annotation
            for dir in certDirs
    ],
  },

  local madkubIstioMadkubVolumeMounts = [
    {
      mountPath: "/maddog-certs/",
      name: "maddog-certs",
    },
    {
      mountPath: "/tokens",
      name: "tokens",
    },
  ],

  madkubIstioMadkubVolumes():: [
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
      "--madkub-endpoint=https://10.254.208.254:32007",  // Check madkubserver-service.jsonnet for why IP
      "--maddog-endpoint=" + configs.maddogEndpoint,
      "--maddog-server-ca=/maddog-certs/ca/security-ca.pem",
      "--madkub-server-ca=/maddog-certs/ca/cacerts.pem",
    ] + $.madkubIstioCertFolders(certDirs) + [
      "--token-folder=/tokens/",
      "--requested-cert-type=client",
      "--ca-folder=/maddog-certs/ca",
    ],
    name: "madkub-init",
    imagePullPolicy: "IfNotPresent",
    volumeMounts: $.madkubIstioCertVolumeMounts(certDirs) + madkubIstioMadkubVolumeMounts,
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
