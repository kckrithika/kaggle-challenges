### Kubernetes yaml files for SAM bits

To do a deployment pick one of the following approaches:

* have kubectl in your path
* set KUBECTLBIN at time of running this script:

```sh
KUBECTLBIN=/Users/thargrove/sam/bin/kubectl ./deploy.sh prd-samtemp
```

* set KUBECTLBIN in you .bash_profile

```sh
export KUBECTLBIN='/Users/thargrove/sam/bin/kubectl'
```

### Kick off a new deployment

* First sync your enlistment!

```sh
$ git checkout master
$ git pull --rebase upstream master
$ git push
```

* Make your changes
* Run deploy.sh:

```sh
$ ./deploy.sh prd-samtemp
```

* Check in your changes
