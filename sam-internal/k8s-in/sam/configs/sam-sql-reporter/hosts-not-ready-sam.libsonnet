{
    name: "Hosts-Not-Ready-Sam",
    note: "",
    multisql: [

    # ===

    {
    name: "API Servers",
    note: "",
    sql: "SELECT * FROM nodeDetailView WHERE Ready != 'True' AND NOT Name like '%minionceph%' and Name like '%kubeapi%'",
    },
    {
    name: "Minions",
    note: "",
    sql: "SELECT * FROM nodeDetailView WHERE Ready != 'True' AND NOT Name like '%minionceph%' and NOT Name like '%kubeapi%'",
    },
    ],
}