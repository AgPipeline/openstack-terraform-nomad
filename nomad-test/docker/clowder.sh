#!/bin/bash

rm -f /home/clowder/RUNNING_PID

#cp /local/custom.conf /home/clowder/custom/custom.conf

python -m SimpleHTTPServer 9000

#exec /home/clowder/bin/clowder -DMONGOUPDATE=1 -DPOSTGRESUPDATE=1 $*
