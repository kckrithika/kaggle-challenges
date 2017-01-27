### How to deploy SAM

Full Instructions: https://git.soma.salesforce.com/sam/sam/wiki/Deploy-SAM

* First sync your enlistment!

```sh
$ git checkout master
$ git pull --rebase upstream master
$ git push
```

* Make your changes to images.jsonnet / config.jsonnet
* Run build.sh
* Check that everything looks good
* Check in your changes
* Wait for a TNRP build
* Log onto a kubeapi machine and run a up-to-date copy of https://git.soma.salesforce.com/sam/sam/blob/master/tools/deploy-sam/deploy.sh
