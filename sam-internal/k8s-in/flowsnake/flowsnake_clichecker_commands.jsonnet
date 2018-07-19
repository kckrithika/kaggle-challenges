local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");

## Sets the test target to 'canary' - Used for toggling test logic that differs between minikube, CI, or canary
local set_test_target = " -Dintegration.test.target=canary";

## Sets the vip that the canary should exercise against. Currently canaries will only monitor their own fleets
local set_vip = " -Dflowsnake.api.host=" + flowsnakeconfig.fleet_vips[estate];

## Sets the environment version to be validated by the canary tests
local set_version(version) = " -Dflowsnake.project.version=" + version;

## Junit and Test artifacts expected on the watchdog-canary image (which parses the cliCheckerFullCommands config)
## Properties have to be passed in prior to junit.jar for correct parsing
local build_run_command(version) = "java -jar " +
                        set_test_target +
                        set_vip +
                        set_version(version) +
                        " junit.jar -cp integration-test.jar -n '.*'";

## Required for standalone junit to find / execute the target test class
local set_test_class(test_name) = " -c com.salesforce.dva.transform.flowsnake." + test_name;

## Builds a single command to be executed by the watchdog's cliChecker. Assumes a common location of the target testclass
##  and no additional parameters to be passed in, junit and test artifacts from the canary-watchdog image, etc.
local build_test_command(test_name, version) = build_run_command(version) + set_test_class(test_name);

local flag_local = std.objectHas(flowsnake_images.feature_flags, "add_local_canary");
local flag_12 = std.objectHas(flowsnake_images.feature_flags, "add_12_canary");
local flag_docker_test = std.objectHas(flowsnake_images.feature_flags, "docker_daemon_monitor");

local build_command_sets = if flag_local then {
    "0.11.0": {
        SparkStandalone: build_test_command('SparkStandaloneDemoJobIT', '0.11.0'),
        SparkLocal: build_test_command('SparkLocalDriverDemoJobIT', '0.11.0'),
   },
} else if !flag_local then {
    "0.11.0": {
        SparkStandalone: build_test_command('SparkStandaloneDemoJobIT', '0.11.0'),
   },
};

local build_12_commands = if flag_12 && flag_local then {
    "0.12.0": {
        SparkStandalone: build_test_command('SparkStandaloneDemoJobIT', '0.12.0'),
        SparkLocal: build_test_command('SparkLocalDriverDemoJobIT', '0.12.0'),
   },
} else if flag_12 && !flag_local then {
    "0.12.0": {
        SparkStandalone: build_test_command('SparkStandaloneDemoJobIT', '0.12.0'),
   },
} else if !flag_12 then {

};

local build_docker_test_commands = if flag_docker_test then {
    DockerDaemon: { DockerDaemon: "/test-docker.sh" },
} else {};

{
    command_sets:: build_command_sets + build_12_commands + build_docker_test_commands,
}
