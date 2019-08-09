#!/bin/bash
set -e

CMD="$@"
if [ ${PICAM_START} = "auto" ] ; then
    CMD="/tmp/startup.sh"
fi
exec ${CMD}
