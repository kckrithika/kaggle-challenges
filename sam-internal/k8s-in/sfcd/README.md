# SFCD Services Production Deployment

## Debugging SAM deployments

```
kubectl -n sam-system logs samcontrol-deployer-5db54b4897-d52w6 samcontrol-deployer | less
```

## SLBs

- [prd-samtwo](http://slb-portal-service.sam-system.prd-samtwo.prd.slb.sfdc.net:9112/)

## SFCD-API FireBOM Webhook

* First sync your enlistment

```sh
$ git checkout master
$ git pull --rebase upstream master
$ git push
```

* Make your changes. If you're upgrading to a new version, you need to modify sfcdimages.jsonnet. If you're enabling a feature flag, you need to modify sfcd_feature_flags.jsonnet.
* Run build.sh
```
./build.sh "prd/prd-samtwo"
```
* Check that generated k8s-out files look good. You can copy the generated yaml files in prd-samtest and manually test it in that environment.
* Ask for 2FA approval
* Wait for Firefly to deliver
* Wait for SAM to deploy

### Endpoints

- [Swagger](https://sfcdapi-firebom-webhook.sfcd.prd-samtwo.prd.slb.sfdc.net:8443/swagger-ui.html)
- [GHE Firebom Webhook](https://sfcdapi-firebom-webhook.sfcd.prd-samtwo.prd.slb.sfdc.net:8443/sfcdapi/v1/webhook/firebom/pipelinetemplates/masterdeploy)
- [GHE Firebom Master Deploy API](https://sfcdapi-firebom-webhook.sfcd.prd-samtwo.prd.slb.sfdc.net:8443/sfcdapi/v1/ghe/firebom/pipelinetemplates/masterdeploy)
- [Firebom Master Deploy API](https://sfcdapi-firebom-webhook.sfcd.prd-samtwo.prd.slb.sfdc.net:8443/sfcdapi/v1/firebom/pipelinetemplates/masterdeploy)

# References
- [Certificates for SAM kPods](https://confluence.internal.salesforce.com/display/SAM/Getting+Certificates+for+SAM+kPods)