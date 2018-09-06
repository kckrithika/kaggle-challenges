# Firefly Production Deployment

## Firefly RabbitMQ

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

## Firefly Services

### Adding a new test repository
* Copy templates/firefly-test-firefly-manifests-svc.jsonnet to templates/firefly-<repository name>-svc.jsonnet.
* Modify the if condition to add or remove kingdoms. 
* Change the queue name to reflect the repository name you are adding. 
* Make a PR and get it approved. 

### Modifying service template
* If you want to add/remove parameters from all services, you need to modify templates/firefly-test-firefly-manifests-svc.jsonnet file.
* If you need to change a specific service, you need to modify the base template for that specific service.
```
  * Package service template: firefly-package-svc.jsonnet.TEMPLATE
  * Pull Request service template: firefly-pullrequest-svc.jsonnet.TEMPLATE
  * Intake Request service template: firefly-intake-svc.jsonnet.TEMPLATE
  * Crawler Request service template: firefly-crawler-svc.jsonnet.TEMPLATE
```

Note: Crawler and Intake a multitenant services. Meaning, a single service instance handlesrequests for multiple GHE repositories. 

### Adding/Modifying environment variables.
Currently, the environment specific parameters are defined in tnrp/firefly_service_conf.jsonnet file. If you want to customize a parameter for a specific environment, change the structure for that environment to override or add. The environmentMapping is used by the service template based on the estate being configured. 

#### Directory structure:

* configs - store any app-specific configs in this directory
* templates - store all K8s jsonnet templates here
* tnrp root directory - images, utilities, feature flags
