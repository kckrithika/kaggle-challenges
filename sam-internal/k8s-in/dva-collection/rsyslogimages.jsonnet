local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local utils = import "util_functions.jsonnet";
local configs = import "config.jsonnet";

{
    # ================== rsyslog RELEASE ====================
    # Releases should follow the order below unless there are special circumstances.  Each phase should use the
    # image from the previous stage after a 24 hour bake time with no issues (check that all watchdogs are healthy)
    ##
    ### Global overrides - Anything here will override anything below
    overrides: {
        #
        # This section lets you override any rsyslog image for a given kingdom,estate,template,image.
        # Image name
        #
        # Example:
        #   # [alias] Added this override to fix issue xxx
        #   "prd,prd-samtwo,rsyslog,rsyslog": "xxxxx",

        },
    
    ### Init containers Definitions
    config_gen_init_container(image_name, template, manifest, output_path):: {
        local cmdline = if manifest == "" then
                "-t " + template + " -o " + output_path
            else
                "-m " + manifest + " -o " + output_path,
        command: [
            "/usr/bin/ruby,
            "/opt/config-gen/config_gen.rb" + cmdline,
        ],
        name: "config-gen",
        image: image_name,
        volumeMounts: rsyslogutils.config_gen_volume_mounts(),
        env: [
            {
                name: "BROKER_VIP",
                value: kafka_vip_from_yaml,
            },
            {
                name: "KAFKA_TOPIC",
                value: kafka_topic_from_yaml,
            },
        ],
    },

    ### Per-phase image tags
    per_phase: {
    ### Release Phase 0 - for sam and samtest
    "0": $.per_phase["1"] {
       rsyslog: "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-devmvp/dva/sfdc_rsyslog_gcp:8.38-PR102",
       config-gen: "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-devmvp/dva/collection-erb-config-gen:v0.1alpha2",
     },

    ### Release Phase 1 - TBD
    "1": $.per_phase["2"] {
       pilot: "N/A",
     },

    ### Release Phase 2 - TBD
    "2": $.per_phase["3"] {
       pilot: "N/A",
     },

    ### Release Phase 3 - TBD
    "3": $.per_phase["4"] {
       pilot: "N/A",
     },

    ### Release Phase 4 - TBD
    "4": {
       pilot: "N/A",
     },
  },

  ### Phase kingdom/estate mapping 
  ### rsyslog daemonset only deploys to GKE sam and samtest for now - other stages are TBD
  phase: (
    if (estate == "gsf-core-devmvp-sam2-sam" || estate == "gsf-core-devmvp-sam2-samtest" || kingdom == "mvp") then
        "0"
    else if (1 == 2) then
        "1"
    else if (1 == 2) then
        "2"
    else if (1 == 2) then
        "3"
    else
        "4"
  ),

}
