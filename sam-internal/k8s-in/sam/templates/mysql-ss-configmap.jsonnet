local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    data: {
        "backup.cnf": |||
        # Apply this config only on backup system
        # To host a backup from a given day - set datadir to /var/lib/mysql-30 (for the 30th)
        [mysql]
        #datadir=/var/lib/mysql/mysql
        #socket=/var/lib/mysql/mysql.sock
        [mysqld]
        log-bin
        #datadir=/var/lib/mysql/mysql
        #socket=/var/lib/mysql/mysql.sock
|||,
        "master.cnf": |||
        # Apply this config only on the master.
        [mysqld]
        log-bin
|||,
        "slave.cnf": |||
        # Apply this config only on slaves.
        [mysqld]
        super-read-only
|||,
},
    kind: "ConfigMap",
    metadata: {
        labels: {
            app: "mysql-ss",
        },
        name: "mysql-ss",
        namespace: "mysql-rep",
    },
    apiVersion: "v1",
} else "SKIP"
