#!/bin/bash
if grep "blocked for more than" /hostkern.log; then
    # TODO: in the future, just exit non-zero so the SAM auto-rebooter can handle
    (
        echo Forcing reboot because btrfs is hung.;
    ) | mail -s "Rebooting $HOSTNAME (TEST EMAIL, DON'T WORRY)" flowsnake@salesforce.com 
    echo "Rebooting in 5 seconds";
    sleep 5;
    # TODO: uncomment after testing
    #echo "b" > /host-proc/sysrq-trigger;
    exit 1;
fi;
