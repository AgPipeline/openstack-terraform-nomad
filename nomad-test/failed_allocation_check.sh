#!/usr/bin/env bash

export LAST_FAILED_ALLOCATION_ID=$(nomad job status clowder | grep " web " | grep " run " | grep " failed " | sed -E "s/ +/,/g" | cut -d "," -f1 | head -n 1)
if [ -z ${LAST_FAILED_ALLOCATION_ID+nothing} ] || [ -z "${LAST_FAILED_ALLOCATION_ID}" ] ;
then
echo "LAST_FAILED_ALLOCATION_ID is unset or empty";
else
echo "LAST_FAILED_ALLOCATION_ID is set to '$LAST_FAILED_ALLOCATION_ID'";
nomad alloc status -verbose $LAST_FAILED_ALLOCATION_ID
fi