{

#### SQL ALERTS ####
#
# These are alerts that fire if any result rows are returned
# Example:
#
# {
#      name: "NameOfSqlCheckNoSpaces",
#      instructions: "Tell the Ops person what to do when this failes.  Please include wiki links.",
#      alertThreshold: "10m",     # This many minutes of continuous failures fires an alert
#      alertFrequency: "24h",     # How often to re-send the alert if it is still broken
#      watchdogFrequency: "10m",  # How often to check the thing
#      alertProfile: "sam",       # Special column telling which team to notify (see watchdog-samsql-profiles.jsonnet)
#      alertAction: "pagerDuty",  # Special column telling which email to use (see watchdog-samsql-profiles.jsonnet)
#      sql: "select * from ..."   # The SQL query.  If the results contain `alertProfile` or `alertAction` they will override this file
#

  sql_alerts: [
    (import "watchdog-samsql-alerts/sladepl.libsonnet"),
    (import "watchdog-samsql-alerts/connectivitychecker.libsonnet"),
    (import "watchdog-samsql-alerts/customerpodswithimagepullerrors.libsonnet"),
    (import "watchdog-samsql-alerts/slanode.libsonnet"),
    (import "watchdog-samsql-alerts/samcontrol.libsonnet"),
    (import "watchdog-samsql-alerts/samappwithoutbundle.libsonnet"),
    (import "watchdog-samsql-alerts/bundlewithoutdeployment.libsonnet"),
    (import "watchdog-samsql-alerts/prlatency.libsonnet"),
    (import "watchdog-samsql-alerts/prfailedtorunevalpr.libsonnet"),
    (import "watchdog-samsql-alerts/prfailedtoproducemanifestzip.libsonnet"),
    (import "watchdog-samsql-alerts/primageunavailable.libsonnet"),
    (import "watchdog-samsql-alerts/kubednspodcount.libsonnet"),
    (import "watchdog-samsql-alerts/kubednspodcount-prod.libsonnet"),
    (import "watchdog-samsql-alerts/kubeapinode.libsonnet").sqlkubeapi("pagerduty", "dist=0"),
    (import "watchdog-samsql-alerts/kubeapinode.libsonnet").sqlkubeapi("businesshours_pagerduty", "dist>0"),
    (import "watchdog-samsql-alerts/autodeployer.libsonnet"),
    (import "watchdog-samsql-alerts/toomanypodsinnamespace.libsonnet"),
  ],


#### ARGUS METRICS ####
#
# These queries run at a fixed interval and each row is written as a metric to argus
#
# The SQL query must have columns for Kingdom, SuperPod, Estate, Metric, Tags, Value.  The watchdog framework builds the metric scope in code.
# See sendDataToArgus() in https://git.soma.salesforce.com/sam/sam/blob/master/pkg/watchdog/internal/checkers/mysqlchecker/mysqlcheckerutils.go
#
# Example:
#
# {
#   name: "NameOfMetricNoSpaces",
#   watchdogFrequency: "10m",      # How often to run this query
#   sql: "select 'prd' as Kingdom, 'NONE' as SuperPod, 'prd-sam' as Estate, 'foo' as Metric, 'color=red' as Tags, 13 as Value",
# }
#

   argus_metrics: [
   (import "watchdog-samsql-metrics/machinecountbykernelversion.libsonnet"),
   (import "watchdog-samsql-metrics/machinecountbykingdomandkernelversion.libsonnet"),
   (import "watchdog-samsql-metrics/mysqlsystemmetrics.libsonnet"),
   (import "watchdog-samsql-metrics/watchdogsuccesspct.libsonnet"),
   (import "watchdog-samsql-metrics/watchdogsuccesscount.libsonnet"),
   (import "watchdog-samsql-metrics/watchdogsuccesspctbykingdom.libsonnet"),
   (import "watchdog-samsql-metrics/sqlnodereadycount.libsonnet"),
   (import "watchdog-samsql-metrics/sql95thpctprlatencyoverlast24hr.libsonnet"),
   (import "watchdog-samsql-metrics/sql95thpctprimagelatencyoverlast24hr.libsonnet"),
   (import "watchdog-samsql-metrics/sql95thpctprtnrplatencyoverlast24hr.libsonnet"),
   (import "watchdog-samsql-metrics/samappsrestatedbysamglobal.libsonnet"),
   (import "watchdog-samsql-metrics/samappsrestatedbysam.libsonnet"),
   (import "watchdog-samsql-metrics/sql95thpctprsamlatencyoverlast24hr.libsonnet"),
   (import "watchdog-samsql-metrics/sqlresourcecounts.libsonnet"),
   (import "watchdog-samsql-metrics/sqlresbyproduceage.libsonnet"),
   (import "watchdog-samsql-metrics/sqlresagebycluster.libsonnet"),
   (import "watchdog-samsql-metrics/hostrepairrebootcount.libsonnet"),
   (import "watchdog-samsql-metrics/hostrepairlast7days.libsonnet"),
   (import "watchdog-samsql-metrics/ipaddresscapacity.libsonnet"),
   (import "watchdog-samsql-metrics/samavailability.libsonnet"),
   (import "watchdog-samsql-metrics/samavailabilityperpool.libsonnet"),
  ],

}
