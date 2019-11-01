# SFCD Services Production Deployment

## Debugging SAM deployments

```
kubectl -n sam-system logs samcontrol-deployer-5db54b4897-d52w6 samcontrol-deployer | less
```

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

