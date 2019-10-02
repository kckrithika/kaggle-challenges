set -xe
# Set pip cache based on platform, set mount flag for MacOS
if [[ "$(uname)" == "Darwin" ]]; then
    PIP_DOWNLOAD_CACHE="${HOME}/Library/Caches/pip"
else
    PIP_DOWNLOAD_CACHE="${HOME}/.cache/pip"
fi

docker run -u 0 --rm -it \
     -v ${PWD}/../../../../..:/manifests\
     -w /manifests \
     centos/python-36-centos7 \
     sh -c "pip -q --cache-dir=${PIP_DOWNLOAD_CACHE} install --upgrade pip && pip -q --cache-dir=${PIP_DOWNLOAD_CACHE} install pyyaml lxml && python /manifests/sam-internal/k8s-in/slb/scripts/ip-reserver/slb-ip-reserver.py /manifests/apps/team /manifests/sam-internal/k8s-in/slb/slbpublicsubnets.json /manifests/sam-internal/k8s-in/slb/slbreservedips.json 1"
