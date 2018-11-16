local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    data: {
        "backup.cnf": |||
        # Apply this config only on backup system
        # To host a backup from a given day _ set datadir to /var/lib/mysql_30 (for the 30th)
        [mysql]
        #datadir=/var/lib/mysql/mysql
        #socket=/var/lib/mysql/mysql.sock
        [mysqld]
        log_bin
        #datadir=/var/lib/mysql/mysql
        #socket=/var/lib/mysql/mysql.sock
|||,
        "master.cnf": |||
        # Apply this config only on the master.
        [mysqld]
        # Configs specific to master
        # log-bin
        binlog_stmt_cache_size=1G
        expire_logs_days=1
        sync_binlog=0
        binlog_row_image=minimal
        binlog_format=MIXED
        # For a detailed explanation of these
        # vars, see https://git.soma.salesforce.com/sam/sam/wiki/MySQL_Performance_Tuning
        innodb_buffer_pool_size=16GiB
        innodb_change_buffer_max_size=50
        innodb_flush_log_at_trx_commit=1 
        innodb_io_capacity=400
        innodb_log_buffer_size=1GiB
        innodb_lock_wait_timeout=10
        bulk_insert_buffer_size=128MiB
        tmp_table_size=1GiB
        max_heap_table_size=1GiB
        skip_name_resolve=1

|||,
        "slave.cnf": |||
        # Apply this config only on slaves.
        [mysqld]
        # Configs specific to replication slaves
        super-read-only
        slave_parallel_workers=128
        slave_pending_jobs_size_max=1GiB
        slave_compressed_protocol=1
        slave_exec_mode=IDEMPOTENT
        # For a detailed explanation of these
        # vars, see https://git.soma.salesforce.com/sam/sam/wiki/MySQL_Performance_Tuning
        innodb_buffer_pool_size=16GiB
        innodb_change_buffer_max_size=50
        innodb_flush_log_at_trx_commit=1 
        innodb_io_capacity=400
        innodb_log_buffer_size=1GiB
        innodb_lock_wait_timeout=10
        bulk_insert_buffer_size=128MiB
        tmp_table_size=1GiB
        max_heap_table_size=1GiB
        skip_name_resolve=1
|||,
},
    kind: "ConfigMap",
    metadata: {
        labels: {
            app: "mysql_ss",
        },
        name: "mysql_ss",
        namespace: "sam-system",
    },
    apiVersion: "v1",
} else "SKIP"
