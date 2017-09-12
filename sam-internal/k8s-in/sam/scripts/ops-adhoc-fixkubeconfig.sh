#/bin/bash -xe

hostname=$(hostname)
# For test, just print what it would be
sed  "s/server: https:.*/server: https:\/\/$HOSTNAME:8000/" /kubeconfig/kubeconfig
# To change the file
# sed -i ''  "s/server: https:.*/server: https:\/\/$HOSTNAME:8000/" /kubeconfig/kubeconfig

# Keep this running so we dont create a crash loop backoff
while true; do sleep 10000; done
