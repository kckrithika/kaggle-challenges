local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
{
    "apiVersion": "sparkoperator.k8s.io/v1beta1",
    "kind": "SparkApplication",
    "metadata": {
        # Name must match filename (because watchdog shell script assumes so).
        # This magic converts e.g. ./flowsnake/templates/watchdog/spark-on-k8s-canary-specs/watchdog-spark-operator.libsonnet -> watchdog-spark-operator
        "thisFile_split":: std.split(std.thisFile,"/"),
        "name": std.splitLimit(self.thisFile_split[std.length(self.thisFile_split) -1],".",1)[0],
        "namespace": "flowsnake-watchdog"
    },
    "spec": {
        "deps": {
            "jars": [
                "local:///sample-apps/sample-spark-operator/extra-jars/*"
            ]
        },
        "driver": {
            "coreLimit": "200m",
            "cores": 0.1,
            "labels": {
                "version": "2.4.0"
            },
            "memory": "512m",
            "serviceAccount": "spark-driver-flowsnake-watchdog"
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
        "mainApplicationFile": "local:///sample-apps/sample-spark-operator/sample-spark-operator.jar",
        "mainClass": "org.apache.spark.examples.SparkPi",
        "mode": "cluster",
        "restartPolicy": {
            "type": "Never"
        },
        "sparkVersion": "",
        "type": "Scala"
    }
}
