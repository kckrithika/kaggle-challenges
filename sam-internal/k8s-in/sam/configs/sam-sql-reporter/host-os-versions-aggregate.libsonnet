{
      name: "Host-Os-Versions-Aggregate",
      sql: "SELECT kernelVersion, COUNT(*) FROM nodeDetailView GROUP BY kernelVersion ORDER BY kernelVersion DESC",
}