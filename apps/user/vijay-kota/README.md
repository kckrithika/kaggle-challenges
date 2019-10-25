This folder contains spikes to testing out functionality on SAM

# prd-cron-test
This is a spike for standing up a test SDB container on SAM for use by cron service. There were 2 attempts:
1. Use private Docker image of one of the SDB architects. Like DBaaS, it tries to use Zookeeper to bring up an HA version of SDB.
   1. Though postgres came up fine, I couldn't get the database to come up.
   1. I didn't follow up further on [Chatter](https://gus.lightning.force.com/lightning/r/0D5B000000x8zMXKAY/view).
1. Next attempt was to use `sdbgo` container with few tweaks. With this I was able to successfully connect to `sdbmain` database

## One-time image creation
1. A base-image of official `sdbgo:v1` was used and some tweaks were made
   1. `docker build -t samhello -f mysdb-Dockerfile .`
   1. `docker tag samhello ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/vijay-kota/mysdb:<tag>`
   1. `docker push ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/vijay-kota/mysdb:<tag>`
1. Changes made to `sdbgo` are as follows:
   1. Download `*.bz2` files from Nexus into same folder as `mysdb-Dockerfile`
      1. See `install.sh` for the Nexus urls to download from
   1. Modify `myinstall.sh` to use the downloaded artifacts
      1. `myinstall.sh` is a copy of `install.sh` that uses hardcoded pre-built tars instead of logging into Nexus and downloading
   1. Instead of user `sdb`, all permissions are given to uid 7447 which is the default in SAM

## Testing
1. Try to locate `psql` - command-line client for SDB. If you cannot find it under `~/blt`, try from CASAM container:
   1. eg. `docker run --network=host --entrypoint /bin/bash -it ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/coreonsam/casam:release_222-patch_18976144`
   1. `cd ~/salesforce/db/sayonaradb/binaries_centos/bin`
1. `./psql -h cs66-sdb-lb.user-vijay-kota.prd-sam.prd.slb.sfdc.net -p 1521 -d sdbmain -U build`
   1. This will take you to prompt where you can run commands
   1. Use `\q` to exit from the shell

# prd-qpid-test and prd-caas-test
This spike is related to [W-6323983](https://gus.lightning.force.com/a07B0000007IlQzIAK). The attempt here is to test:
1. Whether 2 stateful Qpid clusters in different pods can use same AMQP and HTTP port(s)
1. Whether original destination routing (ODR) can be supported by making each Qpid container announce itself using a diff. port

## Topology
1. 2 pods `cs55` and `cs66` are simulated. Each has an "app" server and a stateful Qpid cluster consisting of 2 broker containers
1. Each "broker" container is an HTTP server listening on the AMQP port and spits out ip address and host names (see `myqpid.py`)
1. Each broker is listening on a different AMQP port
1. App server is an HTTP server listening on a port. It looks at GET request url to make a HTTP call to either of the brokers using the specific port
1. Since the app server is mesh-enabled, it addresses the broker using localhost and port number from the GET request (see `myapp.py`)
   * Eg. GET on `http://<app ip>:<app port>/p1` will result in HTTP call to `http://localhost:p1`
   * Because of the way service mesh works (as of July 2019), the announced port is p1-2 and broker is actually listening on p1-1

## One-time image creation
1. A base-image of official Sherpa envoy was used to create the broker and app server
   1. `docker build -t samhello .`
   1. `docker tag samhello ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/vijay-kota/myenvoy:<tag>`
   1. `docker push ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/vijay-kota/myenvoy:<tag>`
   1. Update manifests if needed
1. Official image of beacon is used for announcements

## Working with the manifests
Modify either of the manifest.yaml files and __generate__ the other one. For eg:
* Modify `prd-qpid-test/manifest.yaml`
* `sed -e 's/cs55/cs66/g' prd-qpid-test/manifest.yaml > prd-caas-test/manifest.yaml`

## Conclusion
1. Validation done using PRD switchboard (IP can be obtained from [switchboard service](http://dashboard-prd-sam.csc-sam.prd-sam.prd.slb.sfdc.net/#!/service/service-mesh/switchboard?namespace=service-mesh) in `service-mesh` namespace)
   * Cluster detection failed with `duplicate cluster`. From http://10.240.128.178:15370/manage/metrics 
     ```
     "switchboard.duplicateClusters.mq-cluster9-cs55-2050.qpid.2050": 1,
     "switchboard.duplicateClusters.mq-cluster9-cs55-2053.qpid.2053": 2,
     "switchboard.duplicateClusters.mq-cluster9-cs66-2050.qpid.2050": 1,
     "switchboard.duplicateClusters.mq-cluster9-cs66-2053.qpid.2053": 2,
     ```
   * This is because for the TCP proxy range - [1024 - 5000](https://git.soma.salesforce.com/servicelibs/switchboard/blob/71c8717eb3b01641af6ff9ad87a75a9fa00ebb16/switchboard/src/main/java/com/salesforce/mesh/switchboard/api/ClusterType.java#L23) - switchboard does not allow duplicate ports at DC level (even for pod-level announcements)
1. Different containers in same cluster announcing different ports
   * This will need assumptions about Beacon implementation or changes in Beacon itself

# vips
Example of creating TCP or HTTP VIPs backed by Software Load Balancer (SLB)
