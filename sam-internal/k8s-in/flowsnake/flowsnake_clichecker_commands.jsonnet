local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");
local image_renames_and_canary_build_tags = std.objectHas(flowsnake_images.feature_flags, "image_renames_and_canary_build_tags");

## Sets the test target to 'canary' - Used for toggling test logic that differs between minikube, CI, or canary
local set_test_target = " -Dintegration.test.target=canary";

## Sets the vip that the canary should exercise against. Currently canaries will only monitor their own fleets
local set_vip = " -Dflowsnake.api.host=" + flowsnakeconfig.fleet_vips[estate];

## Sets the environment version to be validated by the canary tests
local set_environment_version(version) = " -Dflowsnake.project.version=" + version;

## Sets the tag of the application to run for the test. Use the same image tag as the environment service for that
## release.
local set_app_image_tag(version) = " -Dflowsnake.build.tag=" + flowsnake_images.version_mapping.main[version];

## Junit and Test artifacts expected on the watchdog-canary image (which parses the cliCheckerFullCommands config)
## Properties have to be passed in prior to junit.jar for correct parsing
local build_run_command(version) = "java -jar " +
                        set_test_target +
                        set_vip +
                        set_environment_version(version) +
                        (if image_renames_and_canary_build_tags then set_app_image_tag(version) else "") +
                        " junit.jar -cp integration-test.jar -n '.*'";

## Required for standalone junit to find / execute the target test class
local set_test_class(test_name) = " -c com.salesforce.dva.transform.flowsnake." + test_name;

## Builds a single command to be executed by the watchdog's cliChecker. Assumes a common location of the target testclass
##  and no additional parameters to be passed in, junit and test artifacts from the canary-watchdog image, etc.
local build_test_command(test_name, version) = build_run_command(version) + set_test_class(test_name);

## Flowsnake release -> Watchdog name -> jUnit Test class
## make sure add watchdog_canary_versions
local tests_for_each_version = {
    "0.11.0": {
        SparkStandalone: 'SparkStandaloneDemoJobIT',
        SparkLocal: 'SparkLocalDriverDemoJobIT',
   },
    "0.12.0": {
        SparkStandalone: 'SparkStandaloneDemoJobIT',
        SparkLocal: 'SparkLocalDriverDemoJobIT',
   },
    "0.12.1": {
        SparkStandalone: 'SparkStandaloneDemoJobIT',
        SparkLocal: 'SparkLocalDriverDemoJobIT',
   },
    "0.12.2": {
        SparkStandalone: 'SparkStandaloneDemoJobIT',
        SparkLocal: 'SparkLocalDriverDemoJobIT',
   },
    "0.12.5": {
       SparkStandalone: 'SparkStandaloneDemoJobIT',
       SparkLocal: 'SparkLocalDriverDemoJobIT',
   },
};

## For each Flowsnake release available current fleet, construct the test commands
local build_canary_commands = {
    [version]: {
        [test]: build_test_command(tests_for_each_version[version][test], version)  # identify jUnit Test class and build command
        for test in std.objectFields(tests_for_each_version[version])  # iterate tests to run against the version
        }
    for version in std.objectFields(flowsnake_images.version_mapping.main)  # iterate versions available in fleet
    if std.objectHas(tests_for_each_version, version)  # ... but skip versions with no known tests
};

local build_docker_test_commands = {
    DockerDaemon: { DockerDaemon: "/test-docker.sh" },
};

local build_btrfs_test_commands = if std.objectHas(flowsnake_images.feature_flags, "btrfs_watchdog_hard_reset") then {
    BtrfsHung: { BtrfsHung: "bash /var/run/check-btrfs/check-btrfs.sh" },
} else {};

local build_spark_operator_test_commands = {
  SparkOperatorTest: {
    SparkOperatorTest: "/watchdog-spark-scripts/analysis.py --hostname $NODENAME --metrics --sfdchosts /sfdchosts/hosts.json --watchdog-config /config/watchdog.json --command /watchdog-spark-scripts/check-spark-operator.sh /strata-test-specs-in/basic-spark-pi.jsonnet",
    # Verify impersonation works at all
    ImpersonationProxyMinimalTest: "/watchdog-spark-scripts/check-impersonation.sh /watchdog-spark-scripts/kubeconfig-impersonation-proxy",
    # Run a Spark Application via the impersonation proxy
    ImpersonationProxySparkTest: "/watchdog-spark-scripts/analysis.py --hostname $NODENAME --metrics --sfdchosts /sfdchosts/hosts.json --watchdog-config /config/watchdog.json --command /watchdog-spark-scripts/check-spark-operator.sh --kubeconfig /watchdog-spark-scripts/kubeconfig-impersonation-proxy /strata-test-specs-in/basic-spark-impersonation.jsonnet",
  } + if flowsnakeconfig.hbase_enabled && std.objectHas(flowsnake_images.feature_flags, "next_analysis_script") then {
    # Run a Hbase integration test
    HbasePhoenixSparkKingdomTestTest: "/watchdog-spark-scripts/analysis.py --hostname $NODENAME --metrics --sfdchosts /sfdchosts/hosts.json --watchdog-config /config/watchdog.json --command /watchdog-spark-scripts/check-spark-operator.sh --hbase-cluster kingdom-test /strata-test-specs-in/hbase-integration.jsonnet",
    HbasePhoenixSparkKingdomPerfTest: "/watchdog-spark-scripts/analysis.py --hostname $NODENAME --metrics --sfdchosts /sfdchosts/hosts.json --watchdog-config /config/watchdog.json --command /watchdog-spark-scripts/check-spark-operator.sh --hbase-cluster kingdom-perf /strata-test-specs-in/hbase-integration.jsonnet",
  } else {},
};
{
    command_sets:: build_canary_commands + build_docker_test_commands + build_btrfs_test_commands + build_spark_operator_test_commands,
}
