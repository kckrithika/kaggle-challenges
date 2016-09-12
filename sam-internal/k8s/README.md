### Kubernetes yaml files for SAM bits

To do a deployment, you need to have kubectl in your path or else set KUBECTLBIN.  Do this with an absolute path:

```sh
export KUBECTLBIN='/Users/thargrove/sam/src/k8s.io/kubernetes/cluster/kubectl.sh'
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
