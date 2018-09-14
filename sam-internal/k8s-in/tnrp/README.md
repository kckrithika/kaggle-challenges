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
Service jsonnets are defined in a hierarchical manner. At the root of the hierarchy is the base service template file **firefly-service-deployment.jsonnet.TEMPLATE**. This file defines a service and deployment kube object of List type. Files that end with .TEMPLATE suffix are not processed by the build script. 

The service specific templates derive from base template and override or add additional configuration data. These are also named .TEMPLATE so they don't get processed. 

The repo specific file can be thought of as an instance or composition of services. It overrides repo specific parameters and merges service and deployment kube object of each service into a single kube yaml file. The repo specific file is what gets ultimately deployed by Kubernetes.

![Kube design](https://docs.google.com/document/d/1xBbcyZQt9sQAU-eAXTCP001BrcKqdFGQLPrb77w1YJI/edit#heading=h.eqvf609sqhzk)

### Adding a new test repository
* Copy templates/firefly-test-firefly-manifests-svc.jsonnet to templates/firefly-repository name-svc.jsonnet.
* Modify the if condition to add or remove kingdoms. 
* Change the queue name to reflect the repository name you are adding. 
* Make a PR and get it approved. 

### Modifying service template
* If you want to add/remove parameters from all services, you need to modify templates/firefly-service-deployment.jsonnet.TEMPLATE file.
* If you need to change a specific service, you need to modify the base template for that specific service.
```
  * Package service template: firefly-package-svc.jsonnet.TEMPLATE
  * Pull Request service template: firefly-pullrequest-svc.jsonnet.TEMPLATE
  * Promotion Request service template: firefly-promotion-svc.jsonnet.TEMPLATE
  * Intake Request service template: firefly-intake-svc.jsonnet.TEMPLATE
  * Crawler Request service template: firefly-crawler-svc.jsonnet.TEMPLATE
```

Note: Crawler and Intake are multitenant services. Meaning, a single service instance can handle requests for multiple git repos. 

### Adding/Modifying environment variables.
Currently, the environment specific parameters are defined in tnrp/firefly_service_conf.jsonnet file. If you want to customize a parameter for a specific environment, change the structure for that environment to override or add. The environmentMapping is used by the service template based on the estate being configured. 

### Running your own instance of service in a different namespace
Following are the steps for running a separate instance of the service for local testing in prdsam:
* ssh to <username>@shared0-samkubeapi2-1-prd.eng.sfdc.net using your kerb password
* scp sam-internal/k8s-out/prd/prd-sam/firefly-test-firefly-manifests-svc.yaml or firefly-test_sam_manifests-svc.yaml to prd-sam /tmp directory
* Edit the file and change the docker image to point to docker-sam repository in your namespace. Make sure you change the build.gradle file of the service you want to test and modify it to push the docker image to your namespace under docker-sam.
* Change **_namespace: firefly_** to **_namespace: firefly[username]_**
* Scale down any instance of the service running on other namespaces for the same repo. If you want to totally avoid any clashes, you can create your own repo and run a single instance of RabbitMq.
* To scale down a service, run **_kubectl scale deployment firefly-[servicename]-[reponame] -n firefly[username] --replicas 0_** example: **_kubectl scale deployment firefly-pullrequest-tfm -n fireflytest --replicas 0_**, where tfm stands for test-firefly-manifests repo under SAM org
* Run **_kubectl create -f /tmp/firefly-test-firefly-manifests-svc.yaml -n firefly<username>_** to create the service
* Ensure services are running **_kubectl get pods -n firefly[username]_**


### Adding your own repository
Following are the steps for creating a separate repository for your own testing needs:
* To create a clone of SAM manifests, you can clone test_sam_manifests under tnrpfirefly repo. 
* To create a service for the new repo, copy firefly-test-firefly-manifests-svc.yaml to a new file firefly-**repo_name**-svc.yaml under sam-internal/k8s-in/tnrp/templates directory.
* Edit the file and change the config.estate based on where you want the service for this repo to run. If you are testing, it is best to stick with prd-sam.
* Change instanceType to the newly created repo. 
* Change the queue names to your repo name. Intake service uses this to know where to route a request. There are some naming conventions followed in the code. For manifests, choose a repo name that has **manifests** in the name.
* Run build.sh under k8s-in directory and raise a PR. 
#### Directory structure:

* configs - store any app-specific configs in this directory
* templates - store all K8s jsonnet templates here
* tnrp root directory - images, utilities, feature flags
