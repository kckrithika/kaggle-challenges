local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
{
    "apiVersion": "sparkoperator.k8s.io/v1beta1",
    "kind": "SparkApplication",
    "metadata": {
        # Name must match filename.
        # This magic converts e.g. ./flowsnake/templates/watchdog/spark-on-k8s-canary-specs/watchdog-spark-operator.libsonnet -> watchdog-spark-operator
        "thisFile_split":: std.split(std.thisFile,"/"),
        "name": std.splitLimit(self.thisFile_split[std.length(self.thisFile_split) -1],".",1)[0],
        "namespace": "flowsnake-watchdog"
    },
    "spec": {
        "deps": {
            "jars": [
                "local:///sample-apps/sample-s3-integration/spark-extra-jars/*"
            ]
        },
        "driver": {
            "coreLimit": "200m",
            "cores": 0.1,
            "labels": {
                "version": "2.4.0"
            },
            "envVars":{
                "AWS_REGION":"us-west-2",
                "S3_BUCKET":"moana-spark-history",
                "S3_PATH":"spark-test",
                "LOG_SPARK_EVENTS_IN_S3":"true",
                "AWS_SSE_KEY":"ea96b117-8eee-4314-b214-8a125eb5242e",
                "DATA_FILE":"/sample-apps/sample-s3-integration/constitution_of_india.txt"
            },
            "memory": "512m",
            "serviceAccount": "spark-driver-flowsnake-watchdog",
            "secrets":[
                {
                   "name":"aws",
                   "path":"/etc/flowsnake/secrets/aws",
                   "secretType":"Generic"
                }
            ]
        },
        "executor": {
            "cores": 1,
            "instances": 1,
            "labels": {
                "version": "2.4.0"
            },
            "memory": "512m"
        },
        "image": flowsnake_images.watchdog_spark_operator,
        "imagePullPolicy": "Always",
        "mainApplicationFile": "local:///sample-apps/sample-s3-integration/spark-s3-integration.jar",
        "mainClass": "com.salesforce.dva.transform.flowsnake.demo.SparkS3Demo",
        "mode": "cluster",
        "restartPolicy": {
            "type": "Never"
        },
        "sparkVersion": "",
        "type": "Scala"
    }
}
