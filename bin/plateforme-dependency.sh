#!/bin/bash

# Requiremnts file should look like this if a custom base_repository is desired
# base-repository=http://gqsdhlqjsdh.qsdqlsdhqsd/dzed.fr
# smtp-relay:0.0.1

# Requiremnts file should look like this if no custom base_repository 
# smtp-relay:0.0.1


ACTION=$1
REQUIREMENTS_FILE=$2
REQUIREMENTS_DEST_FILE="${REQUIREMENTS_FILE}.yml"
BASE_WORKING_DIR="required-services"
WORKING_DIR="${BASE_WORKING_DIR}/$REQUIREMENTS_FILE"

LINE_NUMBER=0
REQUIRED_SERVICES=0
BASE_REPO=$PI_BUILD_SCRIPT_DEFAULT_SERVICE_BASE_REPO

function file_exists () {
    echo "# file_exists $1"
    case $1 in
        file://*) echo "#File mode"
               curl -s --insecure --head -i $1 2> /dev/null
            ;;
        http*) curl -s --insecure --head -i $1 2> /dev/null| grep "HTTP/1.1 200 OK"
            ;;
    esac
}
function get_file () {
    echo "# get_file $1 $2"
    curl -L -v -s -k -o $1 $2 2> /dev/null
}



import(){
  echo "Importing Service Requirements using $PI_BUILD_SCRIPT_DIR"
  MISSING=0
  if  [ ! -d $WORKING_DIR ]; then mkdir -p $WORKING_DIR; fi
  
  echo  "Downloading services requirements ..."
  while  read -r line
  do
           re="^(base-repository=)(.*)$"
           if [[ $LINE_NUMBER -eq 0 ]] && [[ "$line" =~ $re ]] ;then
                   BASE_REPO="${BASH_REMATCH[2]}";
                   echo "Using custom base repo is $BASE_REPO"
           else
                   if [[ $LINE_NUMBER -eq 0 ]] && [[ "$line" =~ $re ]] ;
                           then echo "Using default base repo $BASE_REPO";
                   fi
                   echo "requires $line"
                   re="^([^:]+):(.*)$"
                   if [[ "$line" =~ $re ]] ;then
                           SERVICE_NAME="${BASH_REMATCH[1]}" && SERVICE_VERSION="${BASH_REMATCH[2]}"
                   else
                           echo "$line is not a valid requirement"
                           exit 1
                   fi
                   REQUIRED_FILE=$SERVICE_NAME-$SERVICE_VERSION.tar.gz
                   TARGET_URL=$BASE_REPO$SERVICE_NAME/$SERVICE_VERSION/$REQUIRED_FILE
                   echo "downloading : $TARGET_URL"
                   file_exists $TARGET_URL
                   REQUIRED_EXISTS=$?
		   if [ $REQUIRED_EXISTS -eq 0 ]; then
                     get_file $WORKING_DIR/$REQUIRED_FILE $TARGET_URL
                     echo "Add:  playbooks/configure-${SERVICE_NAME}.yml in $REQUIREMENTS_DEST_FILE"
                     echo "# $SERVICE_NAME:$SERVICE_VERSION" >> $REQUIREMENTS_DEST_FILE
                     echo "- include: playbooks/configure-${SERVICE_NAME}.yml" >> $REQUIREMENTS_DEST_FILE
                   else
                     echo "Missing dependency on [$line]"
                     echo "$TARGET_URL does not exist !!!!"
		     ((MISSING++))
                   fi 
                   ((REQUIRED_SERVICES++))
           fi
           ((LINE_NUMBER++))
  done  < "$REQUIREMENTS_FILE"
  echo  "[ $REQUIRED_SERVICES ] services required"
  if [ $REQUIRED_SERVICES -eq 0 ]; then
    echo "Generating an empty playbook for [$REQUIREMENTS_DEST_FILE]"
    echo "# No actions defined in $REQUIREMENTS_FILE for $REQUIREMENTS_DEST_FILE"> $REQUIREMENTS_DEST_FILE
    echo "- hosts: localhost" >> $REQUIREMENTS_DEST_FILE
    echo "  tasks:" >> $REQUIREMENTS_DEST_FILE
    echo "  - debug: msg=\"nothing to do in [$REQUIREMENTS_FILE]\"" >> $REQUIREMENTS_DEST_FILE
  fi
  if [ $MISSING -gt 0 ]; then
	echo "[ $MISSING ] services required but undefined !!!"
	exit 1;
  fi
}

check() {
  echo "checking : $REQUIREMENTS_FILE"
  nb_services=`find $WORKING_DIR/ -maxdepth 1 -name "*.tar.gz" | wc -l`
  if [ $nb_services -gt 0 ]; then
    for service_archive in $WORKING_DIR/*.tar.gz; do
      echo "gathering requirements info for $service_archive"
      tar xvfz $service_archive -C $WORKING_DIR --wildcards --no-anchored './requirements' 
      servicename=`basename $service_archive`
      requirementfilename=${servicename::-7}
      mv $WORKING_DIR/requirements $WORKING_DIR/${requirementfilename}.requirements
    done
    nb_versioned_modules=`cat  $WORKING_DIR/*.requirements | uniq -c | awk -F ':' '{print $1}'`
    nb_modules=`cat  $WORKING_DIR/*.requirements | awk -F ':' '{print $1}' | uniq -c`
    if [ "$nb_versioned_modules" != "$nb_modules" ]; then
  	echo "There are version mismatch..."
    	echo "Plateforme dependency check passed in [FAILED]"
          echo `cat  $WORKING_DIR/*.requirements | uniq -c `
  	rm -rf $WORKING_DIR/*.requirements
          exit 1
    fi
    rm $WORKING_DIR/*.requirements
  else
    echo "[NO REQUIREMENTS] detected for [$REQUIREMENTS_FILE]"
  fi
  echo "Plateforme dependency check passed in [SUCCESS]"
}

package(){
  mkdir -p dist/playbooks
  echo "packaging : $REQUIREMENTS_FILE"
  for service_archive in $WORKING_DIR/*; do
   tar xvfz $service_archive -C dist
  done
# FIXME:  REQUIREMENTS_DEST_FILE = playbook.yml contenant les include relatifs au dir playbooks/
#  cp $REQUIREMENTS_DEST_FILE dist/playbooks
  cp $REQUIREMENTS_DEST_FILE dist/
}

clean() {
  echo "Cleaning Service Requirements "

  if  [ -d $WORKING_DIR ]; then rm -rf $WORKING_DIR; fi
  if  [ -d $BASE_WORKING_DIR ]; then
    if [ ! "$(ls -A $BASE_WORKING_DIR)" ]; then rm -rf $BASE_WORKING_DIR; fi
  fi
  if  [ -f $REQUIREMENTS_DEST_FILE ]; then rm $REQUIREMENTS_DEST_FILE; fi

}

case "$ACTION" in
	"import")
		import ;;
	"check")
		check ;;
	"package")
		package	;;
	"clean")
		clean ;;
	*)
		echo "Unknown action [$ACTION]" ;;
esac
