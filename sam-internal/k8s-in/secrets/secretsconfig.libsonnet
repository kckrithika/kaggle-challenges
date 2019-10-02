local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local secretsimages = import "secretsimages.libsonnet";
local configs = import "config.jsonnet";

# This file presents shared configurations for Secrets Team templates.
{
  secretsEstates: std.set([
    "prd-sam",
    "xrd-sam",
    "hio-sam",
    "ttd-sam",
  ]),
  isSecretsEstate: std.setMember(estate, $.secretsEstates),

  k4aSamWdEstates: std.set([
    "prd-samtest",
  ]),
  k4aSamWdEnabled: std.setMember(estate, $.k4aSamWdEstates),

  k4aCaimanWdEstates: std.set([
    "prd-sam",
    "xrd-sam",
  ]),
  k4aCaimanWdEnabled: std.setMember(estate, $.k4aCaimanWdEstates),

  samPodSecurityContext: {
    securityContext: {
      fsGroup: 7447,
      runAsNonRoot: true,
      runAsUser: 7447,
    },
  },

  sfdcloc_node_name_env: {
    name: "SFDCLOC_NODE_NAME",
    valueFrom: {
      fieldRef: {
        fieldPath: "spec.nodeName",
      },
    },
  },

  function_namespace_env: {
    name: "FUNCTION_NAMESPACE",
    valueFrom: {
      fieldRef: {
        apiVersion: "v1",
        fieldPath: "metadata.namespace",
      },
    },
  },

  function_instance_name_env: {
    name: "FUNCTION_INSTANCE_NAME",
    valueFrom: {
      fieldRef: {
        apiVersion: "v1",
        fieldPath: "metadata.name",
      },
    },
  },
}
