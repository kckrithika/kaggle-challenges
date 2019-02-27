local util = import "../util.jsonnet";

{
    # Exception for liveness probe, if container image matches any of the below, then livenessprobe is not a required field
    livenessProbeExceptions:: util.AllowedValues([
        "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/dkardach/aqueduct-test-deploy:20170418",
        "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/csc-health/redis:3.2",
        "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/geoip/geoip:latest-0000006-7d845eb4",
        "shared0-samcontrol1-1-prd.eng.sfdc.net:5000/adhoot:rcwd-qualifiednameasdevice",
        "shared0-samcontrol1-1-prd.eng.sfdc.net:5000/ccait-geoip-frontend:1.0.2",
        "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/jbratton/ccait-xlt-agent:4.8.3",
        "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/jan-krueger/ccait-xlt-agent:4.8.3",
        "shared0-samcontrol1-1-prd.eng.sfdc.net:5000/gater-sandbox:dmachak-20170424B",
        "shared0-samcontrol1-1-prd.eng.sfdc.net:5000/geoip-demo:dev",
        "shared0-samcontrol1-1-prd.eng.sfdc.net:5000/geoip:dev",
        "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/jbratton/jbratton-grpc-service:0.0.2",
        "shared0-samcontrol1-1-prd.eng.sfdc.net:5000/sherpa:dev",
        "shared0-samcontrol1-1-prd.eng.sfdc.net:5000/sherpa:joey-5",
        "tnrp/caas/caas-redis:0.1-0000017-13232819",
        "tnrp/caas/caas-redis:0.1-0000024-13415531",
        "tnrp/caas/caas-redis:0.1-13175027-16",
        "tnrp/caas/caas-test:0.1-12623074-62",
        "tnrp/csc-health/health-endpoint-watchdog:health-endpoint-watchdog-0000002-e337db53",
        "tnrp/csc-health/report-collector-availability-watchdog:2.1.0-0000055-cf053cd8",
        "tnrp/csc-health/report-collector-availability-watchdog:2.2.0-0000056-3dbf7901",
        "tnrp/csc-health/report-collector:1.3.0-0034e8be-93",
        "tnrp/csc-health/report-collector:1.4.0-0000106-22c71e3f",
        "tnrp/gater/gater:1.1.0-0000026-13383348",
        "tnrp/gater/gater:1.1.1-0000079-13550320",
        "tnrp/p4tools/redis:3.0.2-01",
        "tnrp/sam/hypersam:sam-0000701-487f2675",
        "shared0-samcontrol1-1-prd.eng.sfdc.net:5000/gater-sandbox:dmachak-20170502A",
        "tnrp/csc-health/health-endpoint-watchdog:health-endpoint-watchdog-0000006-c9f39ecc",
        "shared0-samcontrol1-1-prd.eng.sfdc.net:5000/gater-sandbox:dmachak-20170503B",
        "tnrp/gater/gater:1.1.1-0000028-13622462"
    ]),

    # List and Range of reserved ports that should not be accessed (Range is inclusive)
    reservedPorts:: [
        util.AllowedValues( [ 2379, 2380, 4194, 8000, 8002, 8080, 9099, 9100, 10250, 10251, 10252, 10255, 6412 ] ), 
        util.Range( [ 0, 1024 ] ),
        util.Range( [ 32000, 40000 ] )
    ],

    # Regex for allowed/disallowed host path
    allowedHostPathList:: {
        local directoryNameRegex = "[a-zA-Z-_]",
	    local directoryPathRegex = "([a-zA-Z-_]+/?)+",

        allowed: [
            "^/data/" + directoryPathRegex + "$",
            "^/fastdata/" + directoryPathRegex + "$",
            "^/cowdata/" + directoryPathRegex + "$",
            "^/var/log/" + directoryPathRegex + "$",
            "^/home/caas/" + directoryPathRegex + "$",
            "^/home/sfdc-(" + directoryNameRegex + "+)" + directoryPathRegex + "$"
        ],

        notAllowed: [
            "^(/data/certs).*$"
        ]
    },

    # List of reserved env names that should not be used
    reservedEnvName:: [
        "HOST_TYPE",
        "SFDC_METRICS_SERVICE_HOST",
        "SFDC_METRICS_SERVICE_PORT",
        "FUNCTION_NAMESPACE",
        "FUNCTION_INSTANCE_NAME",
        "FUNCTION_INSTANCE_IP",
        "SFDC_SETTINGS_PATH",
        "SFDC_SETTINGS_SUPERPOD",
        "KINGDOM",
        "ESTATE",
        "SUPERPOD",
        "FUNCTION"
    ],

    // List of SAM and K8s reserved Labels
    reservedLabelsRegex:: [
        "^" + "bundleName" + "$",
        "^" + "deployed_by" + "$",
        "^" + "pod-template-hash" + "$",
        "^" + "controller-revision-hash" + "$",
        "^" + "sam_.*" + "$",
        "^" + ".*kubernetes.io/.*" + "$",
    ],

    // secure registry patterns indicating secure images
    secureRegistry:: [
        "^.*artifactrepo.*$"
    ],

    // Exceptions for insecure images
    insecureImageExceptionSet:: [
        "dummyToEnsureNotEverythingPass"
    ],


###################################### Enable Exceptions #############################################


    Enable_LivenessProbeWhitelist: true,
    Enable_InsecureImageExceptions: true,
}