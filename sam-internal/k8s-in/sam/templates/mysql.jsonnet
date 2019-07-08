local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
local madkub = (import "sammadkub.jsonnet") + { templateFilename:: std.thisFile };

local certDirs = ["cert1"];

if configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "prd-samtwo" || configs.estate == "prd-data-flowsnake" then {
            apiVersion: "apps/v1beta1",
            kind: "StatefulSet",
            metadata: {
                labels: {
                    app: "mysql-pure-cache",
                    sam_app: "mysql-pure-cache",
                    sam_function: "mysql-pure-cache",
                    sam_loadbalancer: "mysql-pure-cache",
                },
                name: if configs.estate == "prd-data-flowsnake" then "mysql" else "mysql-pure-cache",
                namespace: if configs.estate == "prd-data-flowsnake" then "flowsnake" else "sam-system",
            },
            spec: {
              podManagementPolicy: "OrderedReady",
              replicas: 1,
              revisionHistoryLimit: 3,
              selector: {
                  matchLabels: {
                      app: "mysql-pure-cache",
                    },
                },
              serviceName: "mysql-pure-cache-service",
              template: {
                  metadata: {
                      labels: {
                          app: "mysql-pure-cache",
                          sam_app: "mysql-pure-cache",
                          sam_function: "mysql-pure-cache",
                          sam_loadbalancer: "mysql-pure-cache",
                        },
                        annotations: {
                          "madkub.sam.sfdc.net/allcerts":
                            std.manifestJsonEx(
                           {
                            certreqs:
                              [
                                { role: "sam-system.mysql-pure-cache" } + certReq
                                  for certReq in madkub.madkubSamCertsAnnotation(certDirs).certreqs
                                ],
                              }, " "
                            ),
                        },
                    },
                  spec: {
                      nodeSelector: {
                              } +
                              if configs.estate == "prd-samdev" then {
                                  master: "true",
                              } else {
                                  pool: configs.estate,
                              },
                      containers: [
                            {
                              env: [
                                    {
                                      name: "HOST_TYPE",
                                      value: "SAM",
                                    },
                                    {
                                      name: "SFDC_METRICS_SERVICE_HOST",
                                      value: "ajna0-funnel1-0-prd.data.sfdc.net",
                                    },
                                    {
                                      name: "SFDC_METRICS_SERVICE_PORT",
                                      value: "80",
                                    },
                                    {
                                      name: "FUNCTION_NAMESPACE",
                                      valueFrom: {
                                          fieldRef: {
                                              apiVersion: "v1",
                                              fieldPath: "metadata.namespace",
                                            },
                                        },
                                    },
                                    {
                                      name: "FUNCTION_INSTANCE_NAME",
                                      valueFrom: {
                                          fieldRef: {
                                              apiVersion: "v1",
                                              fieldPath: "metadata.name",
                                            },
                                        },
                                    },
                                    {
                                      name: "FUNCTION_INSTANCE_IP",
                                      valueFrom: {
                                          fieldRef: {
                                              apiVersion: "v1",
                                              fieldPath: "status.podIP",
                                            },
                                        },
                                    },
                                    {
                                      name: "FUNCTION",
                                      value: "mysql",
                                    },
                                    {
                                      name: "KINGDOM",
                                      value: "prd",
                                    },
                                    {
                                      name: "ESTATE",
                                      value: "prd-sam",
                                    },
                                    {
                                      name: "SUPERPOD",
                                      value: "None",
                                    },
                                    {
                                      name: "SFDC_SETTINGS_PATH",
                                      value: "-.-.prd.-.mysql",
                                    },
                                    {
                                      name: "SFDC_SETTINGS_SUPERPOD",
                                      value: "-",
                                    },
                                    {
                                      name: "SETTINGS_PATH",
                                      value: "-.-.prd.-.mysql",
                                    },
                                    {
                                      name: "SETTINGS_SUPERPOD",
                                      value: "-",
                                    },
                                    {
                                      name: "MYSQL_ROOT_PASSWORD_FILE",
                                      value: "/var/mysqlPwd/pass.txt",
                                    },
                                    {
                                      name: "MYSQL_USER",
                                      value: "liveness_user",
                                    },
                                    {
                                      name: "MYSQL_PASSWORD",
                                      value: "liveness_password",
                                    },
                                ],
                              image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/d.smith/mysql:20180917_111738.0b5255d9.dirty.duncsmith-ltm",
                              imagePullPolicy: "IfNotPresent",
                              livenessProbe: {
                                  exec: {
                                      command: [
                                          "bash",
                                          "-c",
                                          "mysqladmin ping -u$MYSQL_USER -p$MYSQL_PASSWORD",
                                        ],
                                    },
                                  failureThreshold: 3,
                                  initialDelaySeconds: 30,
                                  periodSeconds: 5,
                                  successThreshold: 1,
                                  timeoutSeconds: 5,
                                },
                              name: "mysql",
                              ports: [
                                    {
                                      containerPort: 3306,
                                      name: "mysql",
                                      protocol: "TCP",
                                    },
                                ],
                              readinessProbe: {
                                  exec: {
                                      command: [
                                          "bash",
                                          "-c",
|||
                                          mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h 127.0.0.1 -e "SELECT 1"
|||,
                                        ],
                                    },
                                  failureThreshold: 3,
                                  initialDelaySeconds: 30,
                                  periodSeconds: 5,
                                  successThreshold: 1,
                                  timeoutSeconds: 5,
                                },
                              resources: {},
                              terminationMessagePath: "/dev/termination-log",
                              terminationMessagePolicy: "File",
                              volumeMounts: [
                                    {
                                      mountPath: "/var/lib/mysql",
                                      name: "mysql-pure-cache-fs",
                                      subPath: "mysql",
                                    },
                                    {
                                      mountPath: "/etc/mysql/conf.d",
                                      name: "conf",
                                    },
                                    {
                                      mountPath: "/certs",
                                      name: "certs",
                                    },
                                    {
                                      mountPath: "/var/mysqlPwd",
                                      name: "mysql",
                                      readOnly: true,
                                    },
                                ],
                            } + configs.ipAddressResourceRequest,
                            {
                              command: [
                                  "bash",
                                  "-c",
|||
                                  set -e
                                  while :
                                  do
                                  mysql -h 127.0.0.1 -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASS < /etc/mysql-users/users.sql || exit 24
                                  mysql -h 127.0.0.1 -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASS < /etc/mysql/schema.sql || exit 25
                                  sleep 300
                                  done
|||,
                                ],
                              env: [
                                    {
                                      name: "MYSQL_ROOT_USER",
                                      value: "root",
                                    },
                                    {
                                      name: "MYSQL_ROOT_PASS",
                                      valueFrom: {
                                          secretKeyRef: {
                                              key: "root",
                                              name: "mysql-passwords",
                                            },
                                        },
                                    },
                                  ],
                              image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/d.smith/mysql:20180917_111738.0b5255d9.dirty.duncsmith-ltm",
                              imagePullPolicy: "IfNotPresent",
                              name: "schema-applier",
                              resources: {},
                              terminationMessagePath: "/dev/termination-log",
                              terminationMessagePolicy: "File",
                              volumeMounts: [
                                    {
                                      mountPath: "/etc/mysql/conf.d",
                                      name: "conf",
                                    },
                                    {
                                      mountPath: "/etc/mysql/",
                                      name: "config-map",
                                    },
                                    {
                                      mountPath: "/etc/mysql-users/",
                                      name: "mysql-users",
                                    },

                                ],
                            },
                        ],
                      dnsPolicy: "ClusterFirst",
                      initContainers: [
                             {
                              args: [
                                  "chmod -R 775 /vols/sam-maddog-cahost",
                                  "chown -R 7447:7447 /vols/sam-maddog-cahost",
                                ],
                              command: [
                                  "/bin/sh",
                                  "-c",
                                ],
                              image: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/hypersam:sam-c07d4afb-673",
                              imagePullPolicy: "Always",
                              name: "permissionsetterinitcontainer",
                              resources: {},
                              securityContext: {
                                  runAsNonRoot: false,
                                  runAsUser: 0,
                                },
                              terminationMessagePath: "/dev/termination-log",
                              terminationMessagePolicy: "File",
                              volumeMounts: [
                                    {
                                      mountPath: "/vols/sam-maddog-cahost",
                                      name: "sam-maddog-cahost",
                                    },
                                ],
                            },
                            {
                              command: [
                                  "bash",
                                  "-c",
|||
                                  set -e
                                  # Generate mysql server-id from pod ordinal index.
                                  [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
                                  ordinal=${BASH_REMATCH[1]}
                                  echo [mysqld] > /mnt/conf.d/server-id.cnf
                                  # Add an offset to avoid reserved server-id=0 value.
                                  echo server-id=$((100 + $ordinal)) >> /mnt/conf.d/server-id.cnf
                                  # Copy appropriate conf.d files from config-map to emptyDir.
                                  if [[ $ordinal -eq 0 ]]; then
                                    cp /mnt/config-map/master.cnf /mnt/conf.d/
                                  else
                                    cp /mnt/config-map/slave.cnf /mnt/conf.d/
                                  fi
|||,
                                ],
                              image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/d.smith/mysql:20180917_111738.0b5255d9.dirty.duncsmith-ltm",
                              imagePullPolicy: "IfNotPresent",
                              name: "init-mysql",
                              resources: {},
                              terminationMessagePath: "/dev/termination-log",
                              terminationMessagePolicy: "File",
                              volumeMounts: [
                                    {
                                      mountPath: "/mnt/conf.d",
                                      name: "conf",
                                    },
                                    {
                                      mountPath: "/mnt/config-map",
                                      name: "config-map",
                                    },
                                ],
                            },
                        ],
                      restartPolicy: "Always",
                      schedulerName: "default-scheduler",
                      securityContext: {},
                      terminationGracePeriodSeconds: 20,
                      volumes: [
                            {
                              emptyDir: {},
                              name: "conf",
                            },
                            {
                              configMap: {
                                  defaultMode: 420,
                                  name: "mysql-inmem",
                                },
                              name: "config-map",
                            },
                            {
                              emptyDir: {
                                  medium: "Memory",
                                },
                              name: "sam-maddog-token",
                            },
                            {
                              emptyDir: {
                                  medium: "Memory",
                                },
                              name: "mysql-pure-cache-fs",
                            },
                            {
                              hostPath: {
                                  path: "/etc/pki_service",
                                },
                              name: "sam-maddog-cahost",
                            },
                            {
                              emptyDir: {
                                  medium: "Memory",
                                },
                              name: "certs",
                            },
                            {
                              name: "mysql",
                              secret: {
                                  defaultMode: 420,
                                  secretName: "mysql-pwd",
                                },
                            },
                            {
                              name: "mysql-users",
                              secret: {
                                  defaultMode: 420,
                                  secretName: "mysql-users",
                                },
                            },
                          ],
                    },
                },
              updateStrategy: {
                  rollingUpdate: {
                      partition: 0,
                    },
                  type: "RollingUpdate",
                },

              },


} else "SKIP"
