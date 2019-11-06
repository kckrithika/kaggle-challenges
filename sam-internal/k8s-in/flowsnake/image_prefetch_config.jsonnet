local flowsnake_images = import "flowsnake_images.jsonnet";

local flowsnake_watchdog_images = [
    "dva/flowsnake-spark-on-k8s-integration-test-runner:" + flowsnake_images.image_tags.integration_test_tag,
    "dva/flowsnake-basic-operator-integration:" + flowsnake_images.image_tags.integration_test_tag,
];

# This file configures which docker images/tags will be prefetched where.
# Images+tags should be added to regional lists WITHOUT an artifactory domain name, e.g.
# dva/app_image_name:35
# NOT
# ops0-artifactrepo2-0-prd.eng.sfdc.net/dva/app_image_name:35

{

    # ALL PROD
    local prod = [
        # CRE Ingest
        "sfci/cre/cre-engine:1.2.1.1.master.871cb95.36",
        # CRE Export
        "sfci/cre/cre-dds-spark:2.1.1.master.07f636a.21",
        # CRE Save
        "sfci/cre/cre-dds-spark:2.1.1.master.07f636a.21",
    ]
    + flowsnake_watchdog_images,


    # PROD BY REGION (for ongoing deployments)
    apac: prod + [

    ],

    na: prod + [

    ],

    emea: prod + [

    ],

    # ALL PRD
    local rnd = [
        # Moana
        "sfci/insights/moanaengine:release-2019.10.a.25-3d1581a",
        # CRE Ingest
        "sfci/cre/cre-engine:1.2.1.1.master.871cb95.36",
        # CRE Export
        "sfci/cre/cre-dds-spark:2.1.1.master.07f636a.21",
        # CRE Save
        "sfci/cre/cre-dds-spark:2.1.1.master.07f636a.21",
    ]
    + flowsnake_watchdog_images,

    # PRD DATA
    "prd-data-flowsnake": rnd + [
    ],

    # PRD DEV
    "prd-dev-flowsnake_iot_test": rnd + [
    ],

    # PRD TEST
    "prd-data-flowsnake_test": rnd + [
    ],


}
