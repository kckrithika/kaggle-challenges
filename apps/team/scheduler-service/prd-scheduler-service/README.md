This is a deployment of Cron service in PRD

## Topology
1. Scheduler service (`cronsvc`) listens on gRPC port 7012 (behind Sherpa)
1. Executor service (`cronexec`) listens on gRPC port 9020 which is unused currently
1. Scheduler UI and demo HTTP endpoint (`cronui`) are accessed via HTTP port 7022
1. Scheduler demo client (`crondemo`) is another HTTP endpoint that can be accessed via HTTP port 9090

## Testing
This can be done either using UI or a simple GET request
1. Create jobs using "Add/Delete Job" from [UI](http://cs101-ui-lb.scheduler-service.prd-sam.prd.slb.sfdc.net:7022/api/v1/index) using input similar to:
   1. A job name of your choice
   1. HTTP endpoint using same jobname: `http://cs101-ui-lb.scheduler-service.prd-sam.prd.slb.sfdc.net:7022/api/v1/demo?q=jobname`. This will hit the demo HTTP endpoint with job name as the query parameter
   1. Cron expression to fire every 30 seconds: `*/30 * * * * ?`
   1. [Demo HTTP endpoint](http://cs101-ui-lb.scheduler-service.prd-sam.prd.slb.sfdc.net:7022/api/v1/demo_triggers) can be used to see how many times the trigger fired
1. Create a job using pre-configured environment variables (see `DEMO_DATA` in manifest)
   1. `curl http://cs101-ui-lb.scheduler-service.prd-sam.prd.slb.sfdc.net:7022/api/v1/demo_add` which creates a job called `DemoClient_50` that fires every 50 seconds hitting the HTTP endpoint hosted by `crondemo`
   1. To verify triggers correctly fired, check container logs at http://dashboard-prd-sam.csc-sam.prd-sam.prd.slb.sfdc.net/#!/pod?namespace=scheduler-service&q=cs101-
      1. Log lines similar to `invoked :DemoClient_50` should be seen
