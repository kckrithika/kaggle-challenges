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
       rsyslog: "15-c26e7af384d606b4862ac824610530b26b5ac579",
       config_gen: "15-14ece1b939b13a42d74ae9fc1ad34d4e674dab73",
       logarchive: "2",
       cadvisor: "v0.30.2",
       cadvisor_scraper: "v0.1alpha3",
       ocagent: "dfc627d96678135648799bc2969f2fe0ce1cc317",
       sherpa: "eeb8e3bfc9d7912299ed28658895aca9523f348f",
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
    rsyslog: "gcr.io/gsf-mgmt-devmvp-spinnaker/dva/sfdc_rsyslog_gcp:" + $.per_phase[$.phase].rsyslog,
    config_gen: "gcr.io/gsf-mgmt-devmvp-spinnaker/dva/collection-erb-config-gen:" + $.per_phase[$.phase].config_gen,
    logarchive: "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-devmvp/dva/sfdc_log_archiver:" + $.per_phase[$.phase].logarchive,
    cadvisor: "k8s.gcr.io/cadvisor:" + $.per_phase[$.phase].cadvisor,
    cadvisor_scraper: "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-devmvp/dva/collection-cadvisor-scraper:" + $.per_phase[$.phase].cadvisor_scraper,
    ocagent: "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-gcp/dva/opencensus-service:" + $.per_phase[$.phase].ocagent,
    sherpa: "ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-gcp/sfci/servicelibs/sherpa-envoy:" + $.per_phase[$.phase].sherpa,
}
