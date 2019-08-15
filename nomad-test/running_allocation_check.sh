#!/usr/bin/env bash

export ALLOCATION_ID=$(nomad job status clowder | grep " web " | grep " running" | sed -E "s/ +/,/g" | cut -d "," -f1 | head -n 1)
if [ -z ${ALLOCATION_ID+nothing} ] || [ -z "${ALLOCATION_ID}" ] ;
then
echo "ALLOCATION_ID is unset or empty";
else
echo "ALLOCATION_ID=$ALLOCATION_ID";
nomad alloc exec $ALLOCATION_ID cat /secrets/custom.env;
#nomad alloc exec $ALLOCATION_ID cat /home/clowder/custom/custom.conf;
#nomad alloc exec $ALLOCATION_ID cat /custom.conf;
#nomad alloc exec $ALLOCATION_ID find / -name 'custom.conf';
#nomad alloc exec $ALLOCATION_ID cat /custom.conf;
nomad alloc exec $ALLOCATION_ID cat /home/clowder/custom/custom.conf;
nomad alloc exec $ALLOCATION_ID env;
fi
