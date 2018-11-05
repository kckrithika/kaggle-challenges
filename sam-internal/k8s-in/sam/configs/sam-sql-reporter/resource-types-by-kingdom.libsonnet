{
    name: "Resource-Types-By-Kingdom",
    sql: "SELECT ControlEstate, ApiKind, Count(*) FROM ( SELECT ControlEstate, ApiKind, IsTombstone FROM k8s_resource where IsTombstone <> 1) AS ss GROUP BY ControlEstate, ApiKind ORDER BY ControlEstate",
}