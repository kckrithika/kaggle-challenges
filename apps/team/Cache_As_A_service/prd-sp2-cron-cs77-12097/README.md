This is a deployment of Cron service in PRD

## Topology
1. Scheduler service (`cronsvc`) listens on gRPC port 7012 (behind Sherpa)
1. Scheduler UI and demo HTTP endpoint (`crondemo`) are accessed via HTTP port 7022
1. Executor service sidecar (`croncar`) listens on gRPC port `localhost:17020` for calls from demo client (`crondemo`)
   1. `crondemo` also has a *debug* HTTP endpoint at `localhost:7022`
1. Mock DBaaS (`cronsdb`) is a dockerized version of SDB

## One-time image creation
1. A base-image of official `sdbgo:v1` was used and some [tweaks](https://git.soma.salesforce.com/sam/manifests/tree/master/apps/user/vijay-kota) were made
1. All cron images were built using sources at https://git.soma.salesforce.com/Scheduler/scheduler-service

## Testing
1. Create a job using "Add Job" from [UI](http://cs77-demo-lb.cache-as-a-service-sp2.prd-samtwo.prd.slb.sfdc.net:7022/api/v1/index)
   1. Can also use pre-configured environment variables (see `DEMO_SVC` in manifest) by calling http://cs77-demo-lb.cache-as-a-service-sp2.prd-samtwo.prd.slb.sfdc.net:7022/api/v1/demo_add
1. Force an `acquireTriggers()` RPC from [demo client](http://cs77-exec-lb.cache-as-a-service-sp2.prd-samtwo.prd.slb.sfdc.net:7022/api/v1/demo_acquire)
   1. `while [ true ]; do curl http://cs77-exec-lb.cache-as-a-service-sp2.prd-samtwo.prd.slb.sfdc.net:7022/api/v1/demo_acquire;sleep 1;done`
   1. Check "Actions" --> "Demo Triggers" from the UI
   1. Check container logs at http://dashboard-prd-samtwo.csc-sam.prd-sam.prd.slb.sfdc.net/#!/search?namespace=cache-as-a-service-sp2&q=cs77-
   1. Log lines regarding triggers, gRPC and HTTP calls should be seen
