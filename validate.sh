#!/bin/bash
echo "NOTE: If the next command gives you an error like 'server gave HTTP response to HTTPS client.' then you most likely are missing the insecure registry setting in docker.  See https://git.soma.salesforce.com/sam/sam/wiki/Set-Up-Docker-For-SAM"
set -xe

#V1
docker run -it --rm -v ${PWD}:/repo/ shared0-samcontrol1-1-prd.eng.sfdc.net:5000/sam-tools /sam/manifest-validator /repo/

#V2
docker run -it --rm -v ${PWD}:/repo/ shared0-samcontrol1-1-prd.eng.sfdc.net:5000/sam-tools:thargrove-20160915_105447-fb609d7 /sam/sam-manifest-builder --root='/repo/' -validateonly 
