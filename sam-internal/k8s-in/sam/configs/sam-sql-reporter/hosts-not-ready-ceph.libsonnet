{
    name: "Hosts-Not-Ready-Ceph",
    sql: "SELECT * FROM nodeDetailView WHERE Ready != 'True' AND Name like '%minionceph%'",
}