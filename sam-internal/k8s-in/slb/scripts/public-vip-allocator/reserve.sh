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
     sh -c "pip -q --cache-dir=${PIP_DOWNLOAD_CACHE} install --upgrade pip && pip -q --cache-dir=${PIP_DOWNLOAD_CACHE} install pyyaml && python /manifests/sam-internal/k8s-in/slb/scripts/public-vip-allocator/slb-public-vip-allocator.py /manifests/apps/team /manifests/sam-internal/k8s-in/slb/slb-config.jsonnet /manifests/sam-internal/k8s-in/slb/slb-reserved-ips.jsonnet /manifests/sam-internal/k8s-in/slb/slb-public-vips.json 0"
