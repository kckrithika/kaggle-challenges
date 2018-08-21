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
            lifecycle: {
              postStart: {
                exec: {
                  command: [
                    '/bin/sh',
                    '-c',
                    'rabbitmqctl wait /var/lib/rabbitmq/mnesia/rabbit\\@$(hostname -f).pid; until rabbitmqctl node_health_check; do sleep 1; done; rabbitmqctl add_user $RABBITMQ_DEFAULT_USER $(pyczar get_secret_by_subscriber --vault-name=${ESTATE} --secret-name=rabbitMqDefaultPass --server-url=https://secretservice.dmz.salesforce.com:8271 --cert-file=/certs/client/certificates/client.pem --key-file=/certs/client/keys/client-key.pem); rabbitmqctl set_user_tags $RABBITMQ_DEFAULT_USER administrator; rabbitmqctl set_permissions -p / $RABBITMQ_DEFAULT_USER ".*" ".*" ".*";',
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
                value: '1.2',
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
              initialDelaySeconds: 30,
              timeoutSeconds: 10,
            },
            readinessProbe: {
              exec: {
                command: [
                  'rabbitmqctl',
                  'node_health_check',
                ],
              },
              initialDelaySeconds: 10,
              timeoutSeconds: 10,
            },
          },
          {
              args: [
                  "/sam/madkub-client",
                  "--madkub-endpoint",
                  "https://10.254.208.254:32007",
                  "--maddog-endpoint",
                  configs.maddogEndpoint,
                  "--maddog-server-ca",
                  "/maddog-certs/ca/security-ca.pem",
                  "--madkub-server-ca",
                  "/maddog-certs/ca/cacerts.pem",
                  "--cert-folders",
                  "certs:/certs/",
                  "--token-folder",
                  "/tokens/",
                  "--requested-cert-type",
                  "client",
                  "--refresher",
                  "--run-init-for-refresher-mode",
                  "--ca-folder",
                  "/maddog-certs/ca",
              ],
              env: [
                  {
                      name: "MADKUB_NODENAME",
                      valueFrom: {
                          fieldRef: {
                              fieldPath: "spec.nodeName",
                          },
                      },
                  },
                  {
                      name: "MADKUB_NAME",
                      valueFrom: {
                          fieldRef: {
                              fieldPath: "metadata.name",
                          },
                      },
                  },
                  {
                      name: "MADKUB_NAMESPACE",
                      valueFrom: {
                          fieldRef: {
                              fieldPath: "metadata.namespace",
                          },
                      },
                  },
              ],
              image: samimages.madkub,
              name: "madkub-refresher",
              resources: {},
              volumeMounts: [
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
