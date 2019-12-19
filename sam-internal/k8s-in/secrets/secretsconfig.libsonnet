local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local secretsimages = import "secretsimages.libsonnet";
local configs = import "config.jsonnet";

# This file presents shared configurations for Secrets Team templates.
{
  statefulsetBase():: {
    local sts = self,
    kind: "StatefulSet",
    apiVersion: "apps/v1beta1",
    spec+: {
      selector: {
        matchLabels: sts.spec.template.metadata.labels,
      },
      template: {
        metadata+: {
          labels+: {
            "sam.data.sfdc.net/owner": "secrets",
          },
        },
      },
    },
  },

  secretsEstates: std.set([
    "prd-sam",
    "xrd-sam",
    "hio-sam",
    "ttd-sam",
    "ast-sam",
    "phx-sam",
    "dfw-sam",
  ]),
  isSecretsEstate: std.setMember(estate, $.secretsEstates),

  # Pin to the sam estate -- our services shouldn't be running in customer estates, and
  # have no need to run on master nodes.
  nodeSelector: {
    nodeSelector: {
      pool: configs.estate,
    },
  },

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
