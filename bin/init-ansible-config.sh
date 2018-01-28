#!/bin/bash
DESTINATION_DIRECTORY=$1
cp $PI_BUILD_SCRIPT_TEMPLATE_DIR/ansible.cfg $DESTINATION_DIRECTORY
if [ $# -gt 1 ]; then
	OPTION=$2
	case $OPTION in
		"log_dest")
			echo "log_path=$3" >> $DESTINATION_DIRECTORY/ansible.cfg
			;;
		*)
			echo "unknown option"		
			exit 1;;
	esac
fi
