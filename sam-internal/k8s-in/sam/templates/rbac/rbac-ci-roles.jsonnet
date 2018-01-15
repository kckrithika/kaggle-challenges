local configs = import "config.jsonnet";
if configs.estate == "prd-sam" then {
  apiVersion: "v1",
  items: [
    {
      apiVersion: "rbac.authorization.k8s.io/v1beta1",
      kind: "RoleBinding",
      metadata: {
        name: "iot-ci:prd-sp2-sam_iot_test:rolebinding",
        namespace: "iot-ci",
      },
      roleRef: {
        apiGroup: "rbac.authorization.k8s.io",
        kind: "ClusterRole",
        name: "minion:role",
      },
      subjects: [
        {
          kind: "User",
          name: "shared0-samminioniottest1-1-prd.eng.sfdc.net",
        },
        {
          kind: "User",
          name: "shared0-samminioniottest1-2-prd.eng.sfdc.net",
        },
        {
          kind: "User",
          name: "shared0-samminioniottest2-1-prd.eng.sfdc.net",
        },
        {
          kind: "User",
          name: "shared0-samminioniottest2-2-prd.eng.sfdc.net",
        },
      ],
    },
    {
      apiVersion: "rbac.authorization.k8s.io/v1beta1",
      kind: "RoleBinding",
      metadata: {
        annotations: null,
        name: "chatbot-ci:prd-sp2-sam_chatbot:rolebinding",
        namespace: "chatbot-ci",
      },
      roleRef: {
        apiGroup: "rbac.authorization.k8s.io",
        kind: "ClusterRole",
        name: "minion:role",
      },
      subjects: [
        {
          apiGroup: "rbac.authorization.k8s.io",
          kind: "User",
          name: "shared0-samminionchatbot1-1-prd.eng.sfdc.net",
        },
        {
          apiGroup: "rbac.authorization.k8s.io",
          kind: "User",
          name: "shared0-samminionchatbot1-2-prd.eng.sfdc.net",
        },
        {
          apiGroup: "rbac.authorization.k8s.io",
          kind: "User",
          name: "shared0-samminionchatbot2-1-prd.eng.sfdc.net",
        },
        {
          apiGroup: "rbac.authorization.k8s.io",
          kind: "User",
          name: "shared0-samminionchatbot2-2-prd.eng.sfdc.net",
        },
      ],
    },
  ],
  kind: "List",
  metadata: {
  },
} else "SKIP"
