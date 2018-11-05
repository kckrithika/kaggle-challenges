{
    name: "Hosts-Kube-Version",
    sql: "SELECT Name, kubeletVersion, Ready FROM nodeDetailView ORDER BY kubeletVersion",
}