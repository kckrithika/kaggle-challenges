local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local utils = import "util_functions.jsonnet";
local configs = import "config.jsonnet";

{
    # ================== Firefly RELEASE ====================
    # Releases should follow the order below unless there are special circumstances.  Each phase should use the
    # image from the previous stage after a 24 hour bake time with no issues (check that all watchdogs are healthy)
    ##

    ### Global overrides - Anything here will override anything below
    overrides: {
        #
        # This section lets you override any Firefly image for a given kingdom,estate,template,image.
        # Image name
        #
        # Example:
        #   # [alias] Added this override to fix issue xxx
        #   "prd,prd-samtwo,firefly-rabbitmq-rcs,rabbitmq": "xxxxx",

        },

    ### Per-phase image tags
    per_phase: {

        ### Release Phase 0 - Nightly deployment of the most recent firefly to prd-samtest
        # Under normal cirumstances we should not need to change this section.
        # Overrides work just fine in this phase.

        # NOTE:
        # Each phase is overlayed on the next phase.  This means that for things that are the same everywhere
        # you are free to simply define it only in Phase4 and all the rest will inherit it.

        ### Release Phase 0 - prd-samtest
        "0": $.per_phase["1"] {
             rabbitmq: "140",
             rabbitmqmonitord: "140",
             },

        ### Release Phase 1 - prd-samdev
        # See https://git.soma.salesforce.com/sam/sam/wiki/Deploy-SAM on how to pick the correct tag
        # As much as possible, we want to use a tag that is running well in phase 0 above.
        # When rolling this phase, remove all overrides from test beds above
        # Make sure there are no critical watchdogs firing before/after the release, and check emails to make sure all rolled properly

        ### Release Phase 1 - prd-samdev
        "1": $.per_phase["2"] {
             rabbitmq: "140",
             rabbitmqmonitord: "140",
            },

        ### Release Phase 2 - prd-sam (Canary)
        "2": $.per_phase["3"] {
<<<<<<< HEAD
<<<<<<< HEAD
             fireflyintake: "439",
             fireflycrawler: "439",
             fireflypackage: "439",
             fireflypromotion: "439",
             fireflypullrequest: "439",
=======
             fireflyintake: "432",
             fireflysecintake: "440",
             fireflycrawler: "432",
             fireflypackage: "432",
             fireflypromotion: "432",
             fireflypullrequest: "432",
>>>>>>> support webhook secret validation
=======
             fireflyintake: "440",
             fireflysecintake: "440",
             fireflycrawler: "440",
             fireflypackage: "440",
             fireflypromotion: "440",
             fireflypullrequest: "440",
>>>>>>> upgrade all images
             fireflyevalresultmonitor: "327",
             fireflydind: "238",
             rabbitmq: "140",
             rabbitmqmonitord: "327",
            },

        ### Release Phase 3 - prd-samtwo (production)
        "3": $.per_phase["4"] {
             fireflyintake: "440",
             fireflysecintake: "440",
             fireflycrawler: "440",
             fireflypackage: "440",
             fireflypromotion: "440",
             fireflypullrequest: "440",
             fireflyevalresultmonitor: "325",
             fireflydind: "238",
             rabbitmq: "140",
             rabbitmqmonitord: "327",
            },

        ### Release Phase 4 - Rest of Prod + Pub + Gia
        "4": {
            },
        },

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-samtest") then
            "0"
        else if (estate == "prd-samdev") then
            "1"
        else if (estate == "prd-sam") then
            "2"
        else if (estate == "prd-samtwo") then
            "3"
        #else
        #    "4"
        ),

    # Static images that do not go in phases
    # [Important Note]: When you are changing images in for initContainers/sidecars  they are not promoted to prod by default. This need to be
    # fixed in the image promotion logic in SMB. For now the workaround is to update the image of a watchdog in one prod DC so that the image is promoted
    # Please be very careful when making such a change
    static: {


    },

    # ====== DO NOT EDIT BELOW HERE ======

    # These are the images used by the templates
    rabbitmq: configs.registry + "/dva/firefly-rabbitmq:" + $.per_phase[$.phase].rabbitmq,
    rabbitmq_monitord: configs.registry + "/dva/firefly-rabbitmq-monitord:" + $.per_phase[$.phase].rabbitmqmonitord,
    fireflyintake: configs.registry + "/dva/firefly-intake:" + $.per_phase[$.phase].fireflyintake,
    fireflysecintake: configs.registry + "/dva/firefly-intake:" + $.per_phase[$.phase].fireflysecintake,
    fireflycrawler: configs.registry + "/dva/firefly-crawler:" + $.per_phase[$.phase].fireflycrawler,
    fireflypullrequest: configs.registry + "/dva/firefly-pullrequest:" + $.per_phase[$.phase].fireflypullrequest,
    fireflypackage: configs.registry + "/dva/firefly-package:" + $.per_phase[$.phase].fireflypackage,
    fireflypromotion: configs.registry + "/dva/firefly-promotion:" + $.per_phase[$.phase].fireflypromotion,
    fireflydind: configs.registry + "/dva/firefly-dind:" + $.per_phase[$.phase].fireflydind,
    fireflyevalresultmonitor: configs.registry + "/dva/firefly-evalresultmonitor:" + $.per_phase[$.phase].fireflyevalresultmonitor,

}
