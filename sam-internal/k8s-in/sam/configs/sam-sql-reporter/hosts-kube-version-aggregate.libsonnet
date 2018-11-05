{
    name: "Hosts-Kube-Version-Aggregate",
    sql: "SELECT Kingdom, kubeletVersion, COUNT(*) FROM nodeDetailView GROUP BY Kingdom, kubeletVersion ORDER BY kubeletVersion",
}