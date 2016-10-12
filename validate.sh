#!/bin/bash
echo "NOTE: If the next command gives you an error like 'server gave HTTP response to HTTPS client.' then you most likely are missing the insecure registry setting in docker.  See https://git.soma.salesforce.com/sam/sam/wiki/Set-Up-Docker-For-SAM"

docker run -it --rm -v ${PWD}:/repo/ shared0-samcontrol1-1-prd.eng.sfdc.net:5000/hypersam:mayank.kumar-20161012_152733-52f8a8a /sam/sam-manifest-builder --root='/repo/' -validateonly

exitcode="$?"
if [ "0" != "$exitcode" ]
then
  echo -e "\033[30;41mValidations failed.  You must fix these before merging!\033[0m"
else
  echo -e "\033[30;42m!!! All validations passed.  You are good to commit !!!\033[0m"
fi
