#!/bin/bash
# Client Env Vars
set -e

if [ "$1" = '%module_name%' ]; then

        echo "******* PROCESSING POST CONFIGURATION *********"
        echo "******* STARTING %MODULE_NAME% *********"
	# command line to start process
	# if process is launched with a start service don't forget to tail it
else
        exec "$@"
fi

