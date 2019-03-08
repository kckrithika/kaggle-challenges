{
  local configs = import "config.jsonnet",
  local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile },

  clientCertConfig(name, mountPath, serviceName, serviceNamespace):: {
    mount: {
      mountPath: mountPath,
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
      role: serviceName + "." + serviceNamespace,
    },
  },

  serverCertConfig(name, mountPath, serviceName, serviceNamespace, subjectAlternativeNames):: {
    mount: {
      mountPath: mountPath,
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
      role: serviceName + "." + serviceNamespace,
      san: subjectAlternativeNames,
    },
  },

  madkubSamCertFolders(certConfigs):: [
    '--cert-folders=%s:%s/' % [c.mount.name, c.mount.mountPath]
    for c in certConfigs
  ],

  madkubSamCertVolumeMounts(certConfigs):: [
    c.mount
    for c in certConfigs
  ],

  madkubSamCertVolumes(certConfigs):: [
    c.volume
    for c in certConfigs
  ],

  madkubSamCertsAnnotation(certConfigs):: {
    certreqs: [
      c.annotation
      for c in certConfigs
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

  madkubInitContainer(certConfigs):: {
    image: "" + samimages.madkub + "",
    args: [
      "/sam/madkub-client",
      # The IP address for the madkub service is hardcoded here:
      # https://git.soma.salesforce.com/sam/manifests/blob/master/sam-internal/k8s-in/sam/templates/madkubserver-service.jsonnet#L18
      "--madkub-endpoint=https://10.254.208.254:32007",
      "--maddog-endpoint=" + configs.maddogEndpoint + "",
      "--maddog-server-ca=/maddog-certs/ca/security-ca.pem",
      "--madkub-server-ca=/maddog-certs/ca/cacerts.pem",
    ] + $.madkubSamCertFolders(certConfigs) + [
      "--token-folder=/tokens/",
      "--ca-folder=/maddog-certs/ca",
    ],
    name: "madkub-init",
    imagePullPolicy: "IfNotPresent",
    volumeMounts: $.madkubSamCertVolumeMounts(certConfigs) + madkubSamMadkubVolumeMounts,
    env: [
      {
        name: "MADKUB_NODENAME",
        valueFrom: {
          fieldRef: { fieldPath: "spec.nodeName", apiVersion: "v1" },
        },
      },
      {
        name: "MADKUB_NAME",
        valueFrom: {
          fieldRef: { fieldPath: "metadata.name", apiVersion: "v1" },
        },
      },
      {
        name: "MADKUB_NAMESPACE",
        valueFrom: {
          fieldRef: { fieldPath: "metadata.namespace", apiVersion: "v1" },
        },
      },
    ],
  },

  madkubRefreshContainer(certConfigs):: $.madkubInitContainer(certConfigs) {
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
