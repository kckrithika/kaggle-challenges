local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local images = import "fireflyimages.jsonnet";
local firefly_feature_flags = import "firefly_feature_flags.jsonnet";
local madkub = (import "firefly_madkub.jsonnet") + { templateFileName:: std.thisFile };
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local permsetter = (import "firefly_permsetter.jsonnet") + { templateFileName:: std.thisFile };

if firefly_feature_flags.is_rabbitmq_enabled then {
  apiVersion: 'apps/v1beta1',
  kind: 'StatefulSet',
  metadata: {
    name: 'rabbitmq',
    namespace: 'firefly',
    labels: {
      name: 'rabbitmq',
    } + configs.ownerLabel.tnrp,
  },
  spec: {
    selector: {
      matchLabels: {
        app: 'rabbitmq',
      },
    },
    serviceName: 'rabbitmq-set',
    replicas: 3,
    updateStrategy: {
        type: "RollingUpdate",
    },
    template: {
      metadata: {
        labels: {
          app: 'rabbitmq',
          name: 'rabbitmq',
        },
        annotations: {
          "madkub.sam.sfdc.net/allcerts": "{\"certreqs\":[{\"name\": \"certs\",\"san\":[\"firefly\"],\"cert-type\":\"client\", \"kingdom\":\"prd\", \"role\": \"firefly\"}]}",
        },
      },
      spec: {
        initContainers: [
            madkub.madkubInitContainer(),
            permsetter.permsetterInitContainer(),
        ],
        containers: [
          {
            name: 'rabbitmq',
            image: images.rabbitmq,
            [if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then "resources"]: configs.ipAddressResource,
            lifecycle: {
              postStart: {
                exec: {
                  command: [
                    '/bin/sh',
                    '-c',
                    '/usr/local/bin/post-start.sh',
                  ],
                },
              },
            },
            imagePullPolicy: 'Always',
            env: [
              {
                name: 'RABBITMQ_DEFAULT_USER',
                value: 'sfdc-rabbitmq',
              },
              {
                name: 'MY_POD_IP',
                valueFrom: {
                  fieldRef: {
                    fieldPath: 'status.podIP',
                  },
                },
              },
              {
                name: 'MY_NODE_NAME',
                valueFrom: {
                  fieldRef: {
                    fieldPath: 'spec.nodeName',
                  },
                },
              },
              {
                name: 'MY_POD_NAME',
                valueFrom: {
                  fieldRef: {
                    fieldPath: 'metadata.name',
                  },
                },
              },
              {
                name: 'MY_POD_NAMESPACE',
                valueFrom: {
                  fieldRef: {
                    fieldPath: 'metadata.namespace',
                  },
                },
              },
              {
                name: 'KINGDOM',
                value: 'PRD',
              },
              {
                name: 'ESTATE',
                value: configs.estate,
              },
              {
                name: 'SFDC_METRICS_SERVICE_HOST',
                value: 'ajna0-funnel1-0-prd.data.sfdc.net',
              },
              {
                name: 'SFDC_METRICS_SERVICE_PORT',
                value: '80',
              },
              {
                name: 'SUPERPOD',
                value: 'NONE',
              },
              {
                name: 'RABBITMQ_USE_LONGNAME',
                value: 'true',
              },
              {
                name: 'RABBITMQ_NODENAME',
                value: 'rabbit@$(MY_POD_NAME).rabbitmq-set.$(MY_POD_NAMESPACE).svc.' + configs.estate + '.' + configs.kingdom + '.sam.sfdc.net.',
              },
              {
                name: 'K8S_SERVICE_NAME',
                value: 'rabbitmq-set',
              },
              {
                name: 'RABBITMQ_CONFIG_VERSION',
                value: '1.0',
              },
              {
                name: 'REDEPLOY_COUNT',
                value: '2',
              },
              {
                name: 'RABBITMQ_MNESIA_BASE',
                value: '/var/lib/rabbitmq/$(MY_POD_NAME)/mnesia',
              },
              {
                name: 'RABBITMQ_SCHEMA_DIR',
                value: '/var/lib/rabbitmq/$(MY_POD_NAME)/schema',
              },
              {
                name: 'RABBITMQ_GENERATED_CONFIG_DIR',
                value: '/var/lib/rabbitmq/$(MY_POD_NAME)/config',
              },
           ],
            ports: [
              {
                name: 'http',
                protocol: 'TCP',
                containerPort: 15672,
              },
              {
                name: 'https',
                protocol: 'TCP',
                containerPort: 15671,
              },
              {
                name: 'amqp',
                protocol: 'TCP',
                containerPort: 5672,
              },
              {
                name: 'amqp-tls',
                protocol: 'TCP',
                containerPort: 5671,
              },
            ],
            volumeMounts: [
              {
                name: 'data-volume',
                mountPath: '/var/lib/rabbitmq',
              },
              {
                name: 'config-volume',
                mountPath: '/etc/rabbitmq',
              },
              {
                  mountPath: "/certs",
                  name: "certs",
              },
            ],
            livenessProbe: {
              exec: {
                command: [
                  'rabbitmqctl',
                  'node_health_check',
                ],
              },
              initialDelaySeconds: 180,
              timeoutSeconds: 60,
              periodSeconds: 30,
              successThreshold: 1,
              failureThreshold: 10,
            },
            readinessProbe: {
              exec: {
                command: [
                  'rabbitmqctl',
                  'await_online_nodes',
                  '2',
                ],
              },
              initialDelaySeconds: 180,
              timeoutSeconds: 60,
              periodSeconds: 30,
              successThreshold: 1,
              failureThreshold: 10,
            },
          },
          madkub.madkubRefreshContainer(),
          {
            name: 'rabbitmq-sidecar',
            image: images.rabbitmq_sidecar,
            securityContext: {
              runAsNonRoot: false,
              runAsUser: 0,
            },
            command: ["java", "-jar", "/home/rabbitmq/rabbitmq-monitor-svc.jar", "--spring.profiles.active=" + configs.estate],
            [if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then "resources"]: configs.ipAddressResource,
            imagePullPolicy: 'Always',
            env: [
              {
                name: 'MY_POD_IP',
                valueFrom: {
                  fieldRef: {
                    fieldPath: 'status.podIP',
                  },
                },
              },
              {
                name: 'MY_NODE_NAME',
                valueFrom: {
                  fieldRef: {
                    fieldPath: 'spec.nodeName',
                  },
                },
              },
              {
                name: 'MY_POD_NAME',
                valueFrom: {
                  fieldRef: {
                    fieldPath: 'metadata.name',
                  },
                },
              },
              {
                name: 'MY_POD_NAMESPACE',
                valueFrom: {
                  fieldRef: {
                    fieldPath: 'metadata.namespace',
                  },
                },
              },
              {
                name: 'KINGDOM',
                value: 'PRD',
              },
              {
                name: 'ESTATE',
                value: configs.estate,
              },
              {
                name: 'SFDC_METRICS_SERVICE_HOST',
                value: 'ajna0-funnel1-0-prd.data.sfdc.net',
              },
              {
                name: 'SFDC_METRICS_SERVICE_PORT',
                value: '80',
              },
              {
                name: 'SUPERPOD',
                value: 'NONE',
              },
              {
                name: 'rabbitMqEndpoint',
                value: 'localhost',
              },
              {
                name: 'rabbitMqApiHttpPort',
                value: '15672',
              },
              {
                name: 'rabbitMqUserName',
                value: 'sfdc-rabbitmq',
              },
              {
                name: 'REDEPLOY_COUNT',
                value: '1',
              },
            ],
            ports: [
              {
                name: 'admin-port',
                protocol: 'TCP',
                containerPort: 8081,
              },
            ],
            volumeMounts: [
              {
                  mountPath: "/root/.ssh/",
                  name: "git-ssh-keys",
              },
              {
                  mountPath: "/certs",
                  name: "certs",
              },
              {
                  mountPath: "/tokens",
                  name: "tokens",
              },
              {
                  mountPath: "/maddog-certs/",
                  name: "maddog-certs",
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/actuator/health',
                port: 'admin-port',
              },
              initialDelaySeconds: 180,
              timeoutSeconds: 60,
              periodSeconds: 30,
              successThreshold: 1,
              failureThreshold: 10,
            },
            readinessProbe: {
              httpGet: {
                path: '/actuator/health',
                port: 'admin-port',
              },
              initialDelaySeconds: 180,
              timeoutSeconds: 60,
              periodSeconds: 30,
              successThreshold: 1,
              failureThreshold: 10,
            },
          },
        ],
        volumes: [
          {
            name: 'data-volume',
            persistentVolumeClaim: {
              claimName: 'firefly-rabbitmq-pv-claim',
            },
          },
          {
            name: 'config-volume',
            projected: {
              sources: [
                {
                  configMap: {
                    name: 'rabbitmq-configmap',
                    items: [
                      {
                        key: 'rabbitmq.conf',
                        path: 'rabbitmq.conf',
                      },
                      {
                        key: 'rabbitmq-env.conf',
                        path: 'rabbitmq-env.conf',
                      },
                      {
                        key: 'enabled_plugins',
                        path: 'enabled_plugins',
                      },
                      {
                        key: 'definitions.json',
                        path: 'definitions.json',
                      },
                    ],
                  },
                },
              ],
            },
          },
          {
              emptyDir: {
                  medium: "Memory",
              },
              name: "certs",
          },
          {
              emptyDir: {
                  medium: "Memory",
              },
              name: "tokens",
          },
          {
              emptyDir: {
                  medium: "Memory",
              },
              name: "git-ssh-keys",
          },
          configs.maddog_cert_volume,
        ],
        terminationGracePeriodSeconds: 10,
        securityContext: {
          fsGroup: 7447,
          runAsNonRoot: true,
          runAsUser: 7447,
        },
        nodeSelector: {
          pool: if configs.estate == "prd-samtwo" then 'prd-sam_tnrp_signer' else configs.estate,
        },
      },
    },
  },
} else "SKIP"
