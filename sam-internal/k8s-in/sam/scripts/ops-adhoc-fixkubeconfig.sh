#/bin/bash -xe

hostname=$(hostname)

# This does an in-place change to the file
sed -i "s/server: https:.*/server: https:\/\/$HOSTNAME:8000/" /kubeconfig/kubeconfig

# Keep this running so we dont create a crash loop backoff
while true; do sleep 10000; done
