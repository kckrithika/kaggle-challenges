{
      name: "Kube-Resource-Kafka-Pipeline-Latencies-ByHour",
      sql: "SELECT Count(*) as Count, avg(diff_seconds), std(diff_seconds), min(diff_seconds), max(diff_seconds), FROM_UNIXTIME(ProduceTime / 1000000000, \"%y-%m-%d %k\") as DayHour
FROM ( SELECT (ConsumeTime - ProduceTime) / 1000000000 AS diff_seconds, ProduceTime FROM k8s_resource ) AS ss
GROUP BY DayHour;",
}