local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local images = import "fireflyimages.jsonnet";
local firefly_feature_flags = import "firefly_feature_flags.jsonnet";

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
      },
      spec: {
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
                    'rabbitmqctl wait /var/lib/rabbitmq/mnesia/rabbit\\@$(hostname -f).pid; until rabbitmqctl node_health_check; do sleep 1; done; rabbitmqctl add_user $RABBITMQ_DEFAULT_USER $RABBITMQ_DEFAULT_PASS; rabbitmqctl set_user_tags $RABBITMQ_DEFAULT_USER administrator; rabbitmqctl set_permissions -p / $RABBITMQ_DEFAULT_USER ".*" ".*" ".*";',
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
                name: 'RABBITMQ_DEFAULT_PASS',
                valueFrom: {
                  secretKeyRef: {
                    name: 'rabbitmq-secret',
                    key: 'rabbitmqDefaultPass',
                  },
                },
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
                  secret: {
                    name: 'rabbitmq-secret',
                    items: [
                      {
                        key: '.erlang.cookie',
                        path: '.erlang.cookie',
                      },
                      {
                        key: 'rabbitmq.pem',
                        path: 'rabbitmq.pem',
                      },
                      {
                        key: 'cacert.pem',
                        path: 'ca/cacert.pem',
                      },
                      {
                        key: 'cert.pem',
                        path: 'server/cert.pem',
                      },
                      {
                        key: 'key.pem',
                        path: 'server/key.pem',
                      },
                    ],
                  },
                },
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
        ],
        terminationGracePeriodSeconds: 10,
        nodeSelector:
          if configs.estate == "prd-samtwo" then {
            pool: 'prd-sam_tnrp_signer',
          } else {
            pool: configs.estate,
        },
      },
    },
  },
} else "SKIP"
