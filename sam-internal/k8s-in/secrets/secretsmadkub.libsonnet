local configs = import "config.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local secretsconfigs = import "secretsconfig.libsonnet";
local secretsimages = import "secretsimages.libsonnet";

{
  certVolumeMounts:: [
    {
      mountPath: "/clientcert",
      name: "client-certs",
    },
  ],

  certVolumes:: [
    {
      emptyDir: {
        medium: "Memory",
      },
      name: "client-certs",
    },
  ],

  certsAnnotation(role):: {
    "madkub.sam.sfdc.net/allcerts":
      std.manifestJsonEx({
        certreqs: [{
          name: "client-certs",
          "cert-type": "client",
          kingdom: configs.kingdom,
          role: role,
        }],
      }, " "),
  },

  local volumeMounts = [
    {
      mountPath: "/maddog-certs/",
      name: "maddog-certs",
    },
    {
      mountPath: "/tokens",
      name: "sam-maddog-token",
    },
  ],

  volumes:: [
    {
      emptyDir: {
        medium: "Memory",
      },
      name: "sam-maddog-token",
    },
    configs.maddog_cert_volume,
  ],

  initContainer:: {
    image: "" + samimages.madkub + "",
    args: [
      "/sam/madkub-client",
      "--madkub-endpoint=https://$(MADKUBSERVER_SERVICE_HOST):32007",
      "--maddog-endpoint=" + configs.maddogEndpoint + "",
      "--maddog-server-ca=/maddog-certs/ca/security-ca.pem",
      "--madkub-server-ca=/maddog-certs/ca/cacerts.pem",
      "--ca-folder=/maddog-certs/ca",
      "--token-folder=/tokens",
      "--funnel-endpoint=" + configs.funnelVIP,
      "--kingdom=" + configs.kingdom,
      "--superpod=None",
      "--estate=" + configs.estate,
      "--testca-folder=/maddog-certs/ca_test",
      "--cert-folders=client-certs:/clientcert",
    ],
    name: "madkub-init",
    imagePullPolicy: "IfNotPresent",
    volumeMounts: $.certVolumeMounts + volumeMounts,
    env: [
      {
        name: "MADKUB_NODENAME",
        valueFrom:
          {
            fieldRef: { fieldPath: "spec.nodeName" },
          },
      },
      {
        name: "MADKUB_NAME",
        valueFrom:
          {
            fieldRef: { fieldPath: "metadata.name" },
          },
      },
      {
        name: "MADKUB_NAMESPACE",
        valueFrom:
          {
            fieldRef: { fieldPath: "metadata.namespace" },
          },
      },
    ],
  },

  refreshContainer:: $.initContainer {
    args+: [
      "--refresher",
      "--run-init-for-refresher-mode",
    ],
    name: "madkub-refresher",
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
