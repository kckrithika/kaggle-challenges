#!/bin/bash

for procdir in /host-proc/*; do
    if [[ -e ${procdir}/status ]] && grep -qP 'Name:[ \t]*kworker' ${procdir}/status && grep -qP 'State:[ \t]*D' ${procdir}/status && grep -q '__lock_page' ${procdir}/stack && grep -qP 'lock.*btrfs' ${procdir}/stack; then
        # TODO: in the future, just exit non-zero so the SAM auto-rebooter can handle
        (
            echo Forcing reboot because btrfs is hung.;
            cat ${procdir}/stack; 
        ) | mail -s "Rebooting $HOSTNAME (TEST EMAIL, DON'T WORRY)" flowsnake@salesforce.com 
        echo "Rebooting in 5 seconds";
        sleep 5;
        # TODO: uncomment after testing
        #echo "b" > /host-proc/sysrq-trigger;
    fi;
done
