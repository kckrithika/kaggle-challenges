{
      name: "Kube-Resource-Kafka-Pipeline-Latencies-ByControlEstate",
      sql: "SELECT min(diff_seconds), avg(diff_seconds), max(diff_seconds), ControlEstate 
FROM ( SELECT (ConsumeTime - ProduceTime) / 1000000000 AS diff_seconds, ControlEstate FROM k8s_resource ) AS ss
GROUP BY ControlEstate",
}