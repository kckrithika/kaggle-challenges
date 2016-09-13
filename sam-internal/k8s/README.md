### Kubernetes yaml files for SAM bits

To do a deployment pick one of the following approaches:
1. have kubectl in your path
2. set KUBECTLBIN at time of running this script:
```sh
KUBECTLBIN=/Users/thargrove/sam/bin/kubectl ./deploy.sh prd-samtemp
```
3. set KUBECTLBIN in you .bash_profile
```sh
export KUBECTLBIN='/Users/thargrove/sam/bin/kubectl'
```

### Kick off a new deployment

1. First sync your enlistment!

```sh
$ git checkout master
$ git pull --rebase upstream master
$ git push
```

2. Make your changes
3. Run deploy.sh:

```sh
$ ./deploy.sh prd-samtemp
```

4. Check in your changes
