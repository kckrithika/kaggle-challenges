local configs = import "config.jsonnet";

std.prune({
  apiServerUrl: "localhost:8000",
})
