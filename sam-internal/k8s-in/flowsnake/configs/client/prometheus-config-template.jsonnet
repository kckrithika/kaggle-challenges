# This is the default config template for client Prometheus instances.
# To use, copy it to a folder with the name of the namespace you're deploying the
# Prometheus into, and then replace the <<YOUR NAMESPACE HERE>> token below
# with the name of the namespace.

{
  global: {
    # Update metrics every minute. This is the finest granularity Argus displays.
    scrape_interval: "60s",
  },
  
  # This section configures posting to the Prometheus-Funnel bridge.
  # Please use it as-is.
  remote_write: [
    {
      url: "http://localhost:8000",
      queue_config: {
        capacity: 100000,
      },
    }
  ],
  
  scrape_configs: [
    {
      job_name: "spark_pods",
      
      # Discovers targets to scrape using Kubernetes.
      # No connection parameters required when deployed by Flowsnake.      
      kubernetes_sd_configs: [
        {
          role: "pod",
          namespaces: {
            names: [ "<<YOUR NAMESPACE HERE>>" ],
          }
        }
      ],
      
      # Rules for k8s-based tags and scrape targets
      relabel_configs: [
        {
          # This rule enables scraping on pods with the correct trigger annotations.
          # These annotations are set by the spark operator when the SparkApplication
          # spec enables monitoring.  Please use this rule as-is.
          action: "keep",
          source_labels: [
            "__meta_kubernetes_pod_annotation_prometheus_io_scrape",
            "__meta_kubernetes_pod_annotation_prometheus_io_port",
          ],
          regex: "true;[0-9]+",
        },
        {
          # This rule causes Prometheus to scrape the port specified in the monitoring
          # configuration section of the SparkApplication rather than any port listed
          # on any container.  Please use this rule as-is.
          action: "replace",
          source_labels: [
            "__meta_kubernetes_pod_annotation_prometheus_io_port",
            "__address__",
          ],
          regex: "([0-9]+);(.*):.*",
          replacement: "${2}:${1}",
          target_label: "__address__",
        },

        # These rules translate Kubernetes/Spark pod attributes into tags for Argus
        {
          source_labels: [ "__meta_kubernetes_pod_node_name" ],
          target_label: "device",
        },
        {
          source_labels: [ "__meta_kubernetes_pod_label_spark_role" ],
          target_label: "spark_role",
        },
        {
          source_labels: [ "__meta_kubernetes_pod_label_spark_exec_id" ],
          target_label: "spark_executor_id",
        },
        {
          source_labels: [ "__meta_kubernetes_pod_label_sparkoperator_k8s_io_app_name" ],
          target_label: "spark_app_name",
        },
      ],
      
      # Rules for metrics and general tags
      metric_relabel_configs: [
        {
          # This tag is always the contents of job_name above and not usually useful; drop to spare Argus
          regex: "job",
          action: "labeldrop",
        },
        {
          # This tag is the IP address of the scraped pod and must be dropped
          # in order to avoid overloading Argus
          regex: "instance",
          action: "labeldrop",
        },
        {
          # Regardless of configuration, the JMX exporter always exposes certain
          # JVM metrics. Without the instance tag to distinguish them, they are all
          # meaningless and would overwrite each other in Argus. So drop them here.
          source_labels: [ "__name__" ],
          regex: "jvm_.*",
          action: "drop",
        },
        
        # JMX Beans sometimes have a "service" label, but this collides with the Argus definition
        # of service.  So copy it to another tag and drop the original.
        {
          source_labels: [ "service" ],
          target_label: "jmx_service"
        },
        {
          regex: "service",
          action: "labeldrop",
        },        
        # Repeat for subservice.
        {
          source_labels: [ "subservice" ],
          target_label: "jmx_subservice"
        },
        {
          regex: "subservice",
          action: "labeldrop",
        },
      ],
    },
  ],
}