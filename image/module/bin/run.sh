#!/bin/sh
# Let SKWR know that the container is up and running
echo "[`hostname -s`] Started"

/opt/src/run.sh
