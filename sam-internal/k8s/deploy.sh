#/bin/bash -xe

# Temporary script to redeploy all our daemon sets and deployments to prd-sam and prd-samemp
# Either put kubectl in your path, or set KUBECTLBIN to point to it.  For example, you can add this to .bash_profile:
#
# export KUBECTLBIN='/Users/thargrove/sam/src/k8s.io/kubernetes/cluster/kubectl.sh'

KUBECTLBIN=${KUBECTLBIN:-kubectl}

case "$1" in
    prd-sam)
        KCONTEXT=prd-sam
        ;;
    prd-samtemp)
        KCONTEXT=prd-samtemp
        ;;
    *)
        echo "Invalid estate $1, use 'prd-sam' or 'prd-samtemp'.  exiting ..."
        exit 1
esac

# TODO: Add warning when running against out-of-sync git repo

echo Context is ${KCONTEXT}, using kubectl ${KUBECTLBIN}

echo Updating debug-portal
${KUBECTLBIN} --context=${KCONTEXT} --namespace=sam-system delete ds debug-portal
${KUBECTLBIN} --context=${KCONTEXT} --namespace=sam-system create -f debug-portal.yaml

echo Updating slam-agent
${KUBECTLBIN} --context=${KCONTEXT} --namespace=sam-system delete ds slam-agent
${KUBECTLBIN} --context=${KCONTEXT} --namespace=sam-system create -f slam-agent.yaml

echo Updating manifest-watcher
${KUBECTLBIN} --context=${KCONTEXT} --namespace=sam-system apply -f manifest-watcher.yaml

echo Updating samcontrol.yaml
${KUBECTLBIN} --context=${KCONTEXT} --namespace=sam-system apply -f samcontrol.yaml

# TODO: Add some basic validations
