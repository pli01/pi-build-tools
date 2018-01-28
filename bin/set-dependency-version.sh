#!/bin/bash

TYPE=$1
DIRECTORY=$2
MODULE_NAME=$3
NEW_VERSION=$4

usage() {
  echo "usage is : $0 service|services|plateforme <directory of service(s)|plateforme> MODULE_NAME NEW_VERSION"
  exit 1
}

setServiceDependency() {
  REQUIREMENT_FILE=$1
  dependency_exists=`grep "$MODULE_NAME:" $REQUIREMENT_FILE | wc -l`
  if [ $dependency_exists -gt 0 ]; then
    echo "$REQUIREMENT_FILE ---> `grep "$MODULE_NAME:" $REQUIREMENT_FILE` --- [BECAME] ---> $MODULE_NAME:$NEW_VERSION"
    sed -i -e "s/^$MODULE_NAME:.*$/$MODULE_NAME:$NEW_VERSION/g" $REQUIREMENT_FILE
  else
     echo "$REQUIREMENT_FILE ---> $MODULE_NAME is not a dependency"
  fi
}

case "$TYPE" in
        "service")
		setServiceDependency $DIRECTORY/requirements
        ;;
        "services")
		for service in $DIRECTORY/* ; do
			setServiceDependency $service/requirements
		done
        ;;
	"plateforme")
		for zone in "zhos" "zps" "zsvc"; do
			setServiceDependency $DIRECTORY/$zone
		done
	;;
        *)
                echo "$TYPE is not a valid type"
                exit 1
esac

