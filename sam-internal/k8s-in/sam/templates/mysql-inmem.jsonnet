local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
local madkub = (import "sammadkub.jsonnet") + { templateFilename:: std.thisFile };

local certDirs = ["cert1"];

if configs.estate == "prd-sam" || configs.estate == "prd-samdev" then {
            apiVersion: "apps/v1beta1",
            kind: "StatefulSet",
            metadata: {
                labels: {
                    app: "mysql-inmem",
                    sam_app: "mysql-inmem",
                    sam_function: "mysql-inmem",
                    sam_loadbalancer: "mysql-inmem",
                },
                name: "mysql-inmem",
                namespace: "sam-system",
            },
            spec: {
              podManagementPolicy: "OrderedReady",
              replicas: 3,
              revisionHistoryLimit: 3,
              selector: {
                  matchLabels: {
                      app: "mysql-inmem",
                    },
                },
              serviceName: "mysql-inmem-service",
              template: {
                  metadata: {
                      labels: {
                          app: "mysql-inmem",
                          sam_app: "mysql-inmem",
                          sam_function: "mysql-inmem",
                          sam_loadbalancer: "mysql-inmem",
                        },
                        annotations: {
                          "madkub.sam.sfdc.net/allcerts":
                            std.manifestJsonEx(
                           {
                            certreqs:
                              [
                                { role: "sam-system.mysql-inmem" } + certReq
                                  for certReq in madkub.madkubSamCertsAnnotation(certDirs).certreqs
                                ],
                              }, " "
                            ),
                        },
                    },
                  spec: {
                      affinity: {
                          nodeAffinity: {
                              requiredDuringSchedulingIgnoredDuringExecution: {
                                  nodeSelectorTerms: [
                                        {
                                          matchExpressions: [
                                                {
                                                  key: "pool",
                                                  operator: "In",
                                                  values: [
                                                      configs.estate,
                                                    ],
                                                },
                                            ],
                                        },
                                    ],
                                },
                            },
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
                                      name: "mysql-inmem-fs",
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
                            },
                            {
                              command: [
                                  "bash",
                                  "-c",
|||
                                  set -e
                                  cd /var/lib/mysql
                                  # Determine binlog position of cloned data, if any.
                                  if [[ -f xtrabackup_slave_info ]]; then
                                    # XtraBackup already generated a partial "CHANGE MASTER TO" query
                                    # because we're cloning from an existing slave.
                                    mv xtrabackup_slave_info change_master_to.sql.in
                                    # Ignore xtrabackup_binlog_info in this case (it's useless).
                                    rm -f xtrabackup_binlog_info
                                  elif [[ -f xtrabackup_binlog_info ]]; then
                                    # We're cloning directly from master. Parse binlog position.
                                    [[ `cat xtrabackup_binlog_info` =~ ^(.*?)[[:space:]]+(.*?)$ ]] || exit 1
                                    rm xtrabackup_binlog_info
                                    echo "CHANGE MASTER TO MASTER_LOG_FILE='${BASH_REMATCH[1]}',
                                          MASTER_LOG_POS=${BASH_REMATCH[2]}" > change_master_to.sql.in
                                  fi
                                  # Check if we need to complete a clone by starting replication.
                                  if [[ -f change_master_to.sql.in ]]; then
                                    echo "Waiting for mysqld to be ready (accepting connections)"
                                    until mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASS -h 127.0.0.1 -e "SELECT 1"; do sleep 1; done
                                    echo "Initializing replication from clone position"
                                    # In case of container restart, attempt this at-most-once.
                                    mv change_master_to.sql.in change_master_to.sql.orig
                                    mysql -h 127.0.0.1 -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASS <<EOF
                                    $(<change_master_to.sql.orig),
                                    MASTER_HOST='mysql-inmem-0.mysql-inmem-service',
                                    MASTER_USER='$MYSQL_ROOT_USER',
                                    MASTER_PASSWORD='$MYSQL_ROOT_PASS',
                                    MASTER_CONNECT_RETRY=10;
                                    START SLAVE;
                                  # This EOF literally needs to be indented like this
                                  # or the script will straight up break. It's loony
                                  EOF
                                  fi
                                  # Start a server to send backups when requested by peers.
                                  exec ncat --listen --keep-open --send-only --max-conns=1 3307 -c "xtrabackup --backup --slave-info --stream=xbstream --host=127.0.0.1 --user=$MYSQL_ROOT_USER --password=$MYSQL_ROOT_PASS"
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
                                              key: "pass.txt",
                                              name: "mysql-pwd",
                                            },
                                        },
                                    },
                                ],
                              image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/d.smith/xtrabackup:1.0",
                              imagePullPolicy: "IfNotPresent",
                              name: "xtrabackup",
                              ports: [
                                    {
                                      containerPort: 3307,
                                      name: "xtrabackup",
                                      protocol: "TCP",
                                    },
                                ],
                              resources: {},
                              terminationMessagePath: "/dev/termination-log",
                              terminationMessagePolicy: "File",
                              volumeMounts: [
                                    {
                                      mountPath: "/var/lib/mysql",
                                      name: "mysql-inmem-fs",
                                      subPath: "mysql",
                                    },
                                    {
                                      mountPath: "/etc/mysql/conf.d",
                                      name: "conf",
                                    },
                                ],
                            },
                            {
                              command: [
                                  "bash",
                                  "-c",
|||
                                  set -e
                                  cd /var/lib/mysql-backups

                                  [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
                                  ordinal=${BASH_REMATCH[1]}
                                  while :
                                  do 
                                    if [[ -f ./restore-me ]]; then
                                      mysql -h 127.0.0.1 -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASS < ./restore-me || exit 24
                                      rm ./restore-me
                                    fi 
                                    echo "Backing up mysql offline db"    
                                    mysqldump -h 127.0.0.1 --all-databases -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASS > mysql-backup-$(date +%d).bkup  
                                    echo "Backup successful\n Purging old logs"
                                    mysql -h 127.0.0.1 -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASS <<EOF
                                    PURGE BINARY LOGS BEFORE NOW() - INTERVAL $BACKUP_INTERVAL_SECONDS SECOND;
                                  EOF
                                    echo "Purge successful. Current disk usage is" 
                                    df -h
                                    sleep $BACKUP_INTERVAL_SECONDS
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
                                    {
                                      name: "BACKUP_INTERVAL_SECONDS",
                                      value: "3600",
                                    },
                                  ],
                              image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/d.smith/mysql:20180917_111738.0b5255d9.dirty.duncsmith-ltm",
                              imagePullPolicy: "IfNotPresent",
                              name: "mysql-dumper",
                              resources: {},
                              terminationMessagePath: "/dev/termination-log",
                              terminationMessagePolicy: "File",
                              volumeMounts: [
                                    {
                                      mountPath: "/var/lib/mysql-backups",
                                      name: "mysql-backup",
                                    },
                                    {
                                      mountPath: "/etc/mysql/conf.d",
                                      name: "conf",
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
                                  "chmod -R 775 /vols/mysql-backup",
                                  "chown -R 7447:7447 /vols/mysql-backup",
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
                                    {
                                      mountPath: "/vols/mysql-backup",
                                      name: "mysql-backup",
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
                            {
                              command: [
                                  "bash",
                                  "-c",
|||
                                  set -e
                                  # Skip the clone if data already exists.
                                  [[ -d /var/lib/mysql/mysql ]] && echo "Mysql data already exists in /var/lib/mysql/mysql. Skipping auto-restore" && exit 0
                                  [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
                                  ordinal=${BASH_REMATCH[1]}
                                  if [[ $ordinal -eq 0 ]]; then
                                    echo "This pod is ss index 0 therefore must be the write master with no data in /mysql . Will only clone from subordinates if clone flag is set"
                                    # If this is master - check for cloning from ro-subordinates 
                                    if [[ $INITIALIZE_EMPTY_MASTER -eq 0 ]]; then
                                      echo "No data found in /var/mysql but the initialize empty flag is not set. This is an invalid state. This pod will remain in crashloopbackoff until either A. This startup script finds a db to start in /var/mysql or B. the INITIALIZE_EMPTY_MASTER flag is set to some value other than 0."
                                      sleep 600
                                      exit 1
                                    else 
                                      echo "Checking for most recent backup file written to durable storage"
                                      if [[ -z "$(ls -A /var/lib/mysql-backups)" ]]; then
                                        echo "No data in backup dir"
                                      else
                                        cd /var/lib/mysql-backups
                                        fn=$(ls -t | head -n1)
                                        mv -f -- "$fn" ./restore-me
                                      fi
                                    fi
                                  else
                                    ## # Clone data from previous peer.
                                    # I don't believe this works for IDEMPOTENT slaves. Trying to set master to 0 to see if that fixes this problem
                                    # ncat --recv-only mysql-inmem-$(($ordinal-1)).mysql-inmem-service 3307 | xbstream -x -C /var/lib/mysql
                                    ncat --recv-only mysql-inmem-0.mysql-inmem-service 3307 | xbstream -x -C /var/lib/mysql
                                    ### Prepare the backup.
                                    xtrabackup --prepare --target-dir=/var/lib/mysql
                                  fi
|||,
                                ],
                              env: [
                                    {
                                      name: "INITIALIZE_EMPTY_MASTER",
                                      value: "1",
                                    },
                                ],
                              image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/d.smith/xtrabackup:1.0",
                              imagePullPolicy: "IfNotPresent",
                              name: "clone-mysql",
                              resources: {},
                              terminationMessagePath: "/dev/termination-log",
                              terminationMessagePolicy: "File",
                              volumeMounts: [
                                    {
                                      mountPath: "/var/lib/mysql",
                                      name: "mysql-inmem-fs",
                                      subPath: "mysql",
                                    },
                                    {
                                      mountPath: "/etc/mysql/conf.d",
                                      name: "conf",
                                    },
                                    {
                                      mountPath: "/var/lib/mysql-backups",
                                      name: "mysql-backup",
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
                              name: "mysql-inmem-fs",
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
                        ],
                    },
                },
              updateStrategy: {
                  rollingUpdate: {
                      partition: 0,
                    },
                  type: "RollingUpdate",
                },
                volumeClaimTemplates: [
                    {
                      metadata: {
                          annotations: {
                              "volume.beta.kubernetes.io/storage-class": "standard-ceph0-hdd-pool",
                            },
                          creationTimestamp: null,
                          name: "mysql-backup",
                        },
                      spec: {
                          accessModes: [
                              "ReadWriteOnce",
                            ],
                          resources: {
                              requests: {
                                  storage: "100Gi",
                                },
                            },
                        },
                    },
                ],
            },

} else "SKIP"
