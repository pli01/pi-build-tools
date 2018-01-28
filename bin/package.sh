#!/bin/bash

TYPE=$1
RELEASE_FILE_NAME=$2
RELEASE_VERSION=$3
RELEASE_COMPONENT_NAME=$4

DIST_DIR=dist

usage() {
  echo "usage is : $0 service|module RELEASE_FILE_NAME RELEASE_VERSION"
  exit 1
}

if [ ! -d $DIST_DIR ]; then mkdir $DIST_DIR; fi
case "$TYPE" in
	"service")
		if [ $# -ne 3 ];then usage;fi
		echo "**** packaging $RELEASE_FILE_NAME version : [$RELEASE_VERSION] ****"
		cp -R roles $DIST_DIR/
		cp -R playbooks $DIST_DIR/
		cp requirements $DIST_DIR
		cd $DIST_DIR/ && find . -type f | xargs tar cvfz $RELEASE_FILE_NAME --exclude tests
	;;
	"module")
		if [ $# -ne 4 ];then usage;fi
		echo "**** packaging $RELEASE_FILE_NAME version : [$RELEASE_VERSION] ****"
		mkdir $DIST_DIR
		cp -R roles $DIST_DIR/
		cd $DIST_DIR/roles/$RELEASE_COMPONENT_NAME && find . -type f | xargs tar cvfz ../../$RELEASE_FILE_NAME --exclude tests
	;;
	*)
		echo "$TYPE is not a valid type"
		exit 1
esac
