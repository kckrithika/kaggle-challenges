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

    ### Per-phase image tags
    per_phase: {
    ### Release Phase 0 - for sam and samtest
    "0": $.per_phase["1"] {
       rsyslog: "8.38-135",
       config_gen: "v0.1alpha2",
     },

    ### Release Phase 1 - TBD
    "1": $.per_phase["2"] {
       rsyslog: "N/A",
       config_gen: "N/A",
     },

    ### Release Phase 2 - TBD
    "2": $.per_phase["3"] {
       rsyslog: "N/A",
       config_gen: "N/A",
     },

    ### Release Phase 3 - TBD
    "3": $.per_phase["4"] {
       rsyslog: "N/A",
       config_gen: "N/A",
     },

    ### Release Phase 4 - TBD
    "4": {
       rsyslog: "N/A",
       config_gen: "N/A",
     },
    },

    ### Phase kingdom/estate mapping 
    ### rsyslog daemonset only deploys to GKE sam and samtest for now - other stages are TBD
    phase: (
        if (kingdom == "mvp") then
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

    # These are the images used by the templates
    rsyslog: "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-devmvp/dva/sfdc_rsyslog_gcp:" + $.per_phase[$.phase].rsyslog,
    config_gen: "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-devmvp/dva/collection-erb-config-gen:" + $.per_phase[$.phase].config_gen,

}
