# To run this locally before merge, follow instructions here: https://git.soma.salesforce.com/sam/sam/tree/master/pkg/sam-sql-reporter

local bedhealth = (import "sam-sql-reporter/bedhealth.libsonnet").bedhealth;

{
  queries: [

#
# Queries in this file can be one of two forms:
#
# == Single SQL query.  Page will have a single table ==
#
#    {
#      name: "Name of query page",
#      note: "Some note to put above the query".
#      sql: "select 123 as A",
#    },
#
# == Multi-sql query.  This will generate a page with many tables ==
#
#    {
#      name: "Name of page",
#      note: "Some top-level note",
#      multisql: [
#        {
#          name: "Name of this result set",
#          note: "Nodes",
#          sql: "select 123 as A",
#        }
#      ],
#    }

    bedhealth("R&D", "prd-samdev"),
    bedhealth("R&D", "prd-samtest"),
    bedhealth("R&D", "prd-sam"),
    bedhealth("R&D", "prd-samtwo"),
    bedhealth("R&D", "xrd-sam"),

    bedhealth("PROD", "cdg-sam"),
    bedhealth("PROD", "cdu-sam"),
    bedhealth("PROD", "chx-sam"),
    bedhealth("PROD", "dfw-sam"),
    bedhealth("PROD", "fra-sam"),
    bedhealth("PROD", "frf-sam"),
    bedhealth("PROD", "hio-sam"),
    bedhealth("PROD", "hnd-sam"),
    bedhealth("PROD", "ia2-sam"),
    bedhealth("PROD", "ia4-sam"),
    bedhealth("PROD", "ia5-sam"),
    bedhealth("PROD", "iad-sam"),
    bedhealth("PROD", "ord-sam"),
    bedhealth("PROD", "par-sam"),
    bedhealth("PROD", "ph2-sam"),
    bedhealth("PROD", "phx-sam"),
    bedhealth("PROD", "syd-sam"),
    bedhealth("PROD", "ttd-sam"),
    bedhealth("PROD", "ukb-sam"),
    bedhealth("PROD", "wax-sam"),
    bedhealth("PROD", "yhu-sam"),
    bedhealth("PROD", "yul-sam"),

    (import "sam-sql-reporter/kube-resource-kafka-pipeline-latencies-bycontrolestate.libsonnet"),
    (import "sam-sql-reporter/kube-resource-kafka-pipeline-latencies-byhour.libsonnet"),
    (import "sam-sql-reporter/host-os-versions-aggregate.libsonnet"),
    (import "sam-sql-reporter/host-os-versions.libsonnet"),
    (import "sam-sql-reporter/hosts-all.libsonnet"),
    (import "sam-sql-reporter/hosts-not-ready-sam.libsonnet"),
    (import "sam-sql-reporter/hosts-not-ready-ceph.libsonnet"),
    (import "sam-sql-reporter/hosts-docker-version.libsonnet"),
    (import "sam-sql-reporter/hosts-kube-version.libsonnet"),
    (import "sam-sql-reporter/hosts-kube-version-aggregate.libsonnet"),
    (import "sam-sql-reporter/resource-types-by-kingdom.libsonnet"),
    (import "sam-sql-reporter/watchdog-aggregate-status-by-checker.libsonnet"),
    (import "sam-sql-reporter/bad-customer-deployments-production.libsonnet"),
    (import "sam-sql-reporter/bad-customer-pods.libsonnet"),
    (import "sam-sql-reporter/image-pull-errors.libsonnet"),
    (import "sam-sql-reporter/sam-app-pod-age-all-kingdoms.libsonnet"),
    (import "sam-sql-reporter/sam-app-pod-age-prd.libsonnet"),
    (import "sam-sql-reporter/mysql-pods-with-old-produce-age.libsonnet"),
    (import "sam-sql-reporter/prd-sandbox-ips-used-by-node.libsonnet"),
    (import "sam-sql-reporter/prd-all-ips-used-by-node.libsonnet"),
    (import "sam-sql-reporter/pods-pending-on-nodes-without-free-ips.libsonnet"),
    (import "sam-sql-reporter/samsystem-overview.libsonnet"),
    (import "sam-sql-reporter/samsystem-failed-pods-sam.libsonnet"),
    (import "sam-sql-reporter/samsystem-failed-pods-nonsam.libsonnet"),
    (import "sam-sql-reporter/minion-pool-utilization-per-kingdom.libsonnet"),
    (import "sam-sql-reporter/minion-pool-utilization-per-role.libsonnet"),
    (import "sam-sql-reporter/fschecker-errors-agg.libsonnet"),
    (import "sam-sql-reporter/fschecker-errors.libsonnet"),
    (import "sam-sql-reporter/hypersam-docker-tags-in-prd.libsonnet"),
    (import "sam-sql-reporter/mysql-pods-by-produce-age.libsonnet"),
    (import "sam-sql-reporter/sam-node-status-aggregate.libsonnet"),
    (import "sam-sql-reporter/watchdog-failure-detail-prod-kingdoms.libsonnet"),
    (import "sam-sql-reporter/watchdog-failure-detail-rnd-kingdoms.libsonnet"),
    (import "sam-sql-reporter/ci-overview.libsonnet"),
    (import "sam-sql-reporter/v2-latency.libsonnet"),
    (import "sam-sql-reporter/failedcreatepodsandbox.libsonnet"),
    (import "sam-sql-reporter/pr-metrics.libsonnet"),
    (import "sam-sql-reporter/customer-app-restarts-by-sam-in-test-beds.libsonnet"),
    (import "sam-sql-reporter/sandbox-ips-by-user.libsonnet"),
    (import "sam-sql-reporter/bad-customer-deployments-v2.libsonnet"),
    (import "sam-sql-reporter/host-repair.libsonnet"),
    (import "sam-sql-reporter/sam-internal-image-tag-global-view.libsonnet"),
    (import "sam-sql-reporter/prd-sam-pods-missing-ip-address.libsonnet"),
    (import "sam-sql-reporter/prd-sam-ip-capacity.libsonnet"),
    (import "sam-sql-reporter/etcd-node-overview.libsonnet"),
    (import "sam-sql-reporter/nodeEndpoint-failure-detail.libsonnet"),
    (import "sam-sql-reporter/prd-sam-sandbox-resources.libsonnet"),
    (import "sam-sql-reporter/sam-customer-stats.libsonnet"),
  ],
}
