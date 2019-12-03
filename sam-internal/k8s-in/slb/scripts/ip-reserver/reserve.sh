set -xe
# Set pip cache based on platform, set mount flag for MacOS
if [[ "$(uname)" == "Darwin" ]]; then
    PIP_DOWNLOAD_CACHE="${HOME}/Library/Caches/pip"
else
    PIP_DOWNLOAD_CACHE="${HOME}/.cache/pip"
fi

output=$(docker run -u 0 --rm \
     -v ${PWD}/../../../../..:/manifests\
     -w /manifests \
     centos/python-36-centos7 \
     sh -c "pip -q --cache-dir=${PIP_DOWNLOAD_CACHE} install --upgrade pip && pip -q --cache-dir=${PIP_DOWNLOAD_CACHE} install pyyaml lxml && python /manifests/sam-internal/k8s-in/slb/scripts/ip-reserver/main.py /manifests/apps/team /manifests/sam-internal/k8s-in/slb/slbpublicsubnets.json /manifests/sam-internal/k8s-in/slb/slbreservedips.json /manifests/sam-internal/pools 1")

estates=$(echo "$output" | tail -n 1)

if [ "$estates" != "No IP reservation changes found" ]; then
  ./../../../build.sh "$estates"
fi

# Print the output ignoring the estates
echo "$output" | sed '$d'