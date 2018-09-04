## How to deploy TnRP Services

### Firefly RabbitMQ

* First sync your enlistment!

```sh
$ git checkout master
$ git pull --rebase upstream master
$ git push
```

* Make your changes. If you're upgrading to a new Docker RabbitMQ image, you need to modify fireflyimages.jsonnet. If you're enabling a feature flag, you need to modify firefly_feature_flags.jsonnet.
* Run build.sh
```
./build.sh "prd/prd-sam,prd/prd-samtwo,prd/prd-samdev,prd/prd-samtest"
```
* Check that generated k8s-out files look good. You can copy the generated yaml files in prd-samtest and manually test it in that environment.
* Ask for 2FA approval
* Wait for a TNRP build

#### Things to note:

* The statefulset `firefly-rabbitmq-rcs` requires a PersistentVolume and PersistentVolumeClaim K8s kinds but they're not currently supported by SAM's auto-deployer. Hence, we have to set those up manually. The `/data/firefly` directory needs to be manually created with 776 mode and owner of 7447:7447 on each SAM minion where the SS could potentially be created.

```
mkdir -m 776 -p /data/firefly
chown 7447:7447 /data/firefly
```

* Docker image is built using Strata CI: https://dva-ci.internal.salesforce.com/job/tnrpfirefly/job/firefly/
* Git repo: https://git.soma.salesforce.com/tnrpfirefly/firefly/rabbitmq/docker
* If you need to upgrade Erlang or RabbitMQ RPMs, please follow the instructions here https://salesforce.quip.com/AHWRA7d3atlP. Once the RPMs are in the isd repo, you need to trigger a new firefly-rabbitmq Docker image build by changing any file on the docker-rabbitmq repo and committing it.
* Reference the [Best Practices](https://git.soma.salesforce.com/sam/sam/wiki/Sam-Internals-Best-Practices) link if you have any questions. Please feel free to contribute there if you encounter a new issue/question.

#### Directory structure:

* configs - store any app-specific configs in this directory
* templates - store all K8s jsonnet templates here
* tnrp root directory - images, utilities, feature flags