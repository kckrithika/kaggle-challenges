To add a query here please remember to add the new include to `../watchdog-samsql-queries.jsonnet`.

Also, to test changes follow instructions here: https://git.soma.salesforce.com/sam/sam/blob/master/pkg/watchdog/internal/checkers/mysqlchecker/README.md

Your metrics query MUST have the following columns:

1. Kingdom - Use `GLOBAL` for global.
1. SuperPod - Use `NONE` for global.
1. Estate - Use `global` for global.
1. Metric - Suggested meric names start with `sql.` and after that use camelCase.
1. Value - The number value.
1. Tags - Format is `A=B`

Every row returned is a different metric.
