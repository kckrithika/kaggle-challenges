FROM ops0-artifactrepo1-0-prd.data.sfdc.net/sfci/servicelibs/sherpa-envoy:1.0.7

WORKDIR /home/sfdc-sherpa
RUN mkdir -p myscripts
COPY --chown=7447:7447 myqpid.py ./myscripts/myqpid.py
COPY --chown=7447:7447 myapp.py ./myscripts/myapp.py
