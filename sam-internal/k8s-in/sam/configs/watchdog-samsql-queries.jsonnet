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
    (import "watchdog-samsql-alerts/sqlsladepl.libsonnet"),
    (import "watchdog-samsql-alerts/customerpodswithimagepullerrors.libsonnet"),
    (import "watchdog-samsql-alerts/sqlslanode.libsonnet"),
    (import "watchdog-samsql-alerts/sqlkubeapinode.libsonnet"),
    (import "watchdog-samsql-alerts/sqlsamcontrol.libsonnet"),
    (import "watchdog-samsql-alerts/sqlsamappwithoutbundle.libsonnet"),
    (import "watchdog-samsql-alerts/sqlbundlewithoutdeployment.libsonnet"),
    (import "watchdog-samsql-alerts/sqlprlatency.libsonnet"),
    (import "watchdog-samsql-alerts/sqlprauthroizationlinkposttimelatency.libsonnet"),
    (import "watchdog-samsql-alerts/sqlprfailedtorunevalpr.libsonnet"),
    (import "watchdog-samsql-alerts/sqlprfailedtoproducemanifestzip.libsonnet"),
    (import "watchdog-samsql-alerts/sqlprimageunavailable.libsonnet"),
    (import "watchdog-samsql-alerts/kubednspodcount.libsonnet"),
    (import "watchdog-samsql-alerts/kubednspodcount-prod.libsonnet"),
    (import "watchdog-samsql-alerts/sqlkubeapinode.libsonnet").sqlkubeapi("pagerduty", "dist=0"),
    (import "watchdog-samsql-alerts/sqlkubeapinode.libsonnet").sqlkubeapi("businesshours_pagerduty", "dist>0"),
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
  ],

}
