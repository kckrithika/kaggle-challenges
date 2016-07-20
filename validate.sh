#!/bin/bash -xe
docker run -it --rm -v ${PWD}:/repo/ shared0-samcontrol1-1-prd.eng.sfdc.net:5000/sam-tools /sam/manifest-validator /repo/
