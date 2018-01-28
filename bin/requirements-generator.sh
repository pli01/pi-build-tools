#!/bin/bash

# Requiremnts file should look like this if a custom base_repository is desired
# base-repository=http://gqsdhlqjsdh.qsdqlsdhqsd/dzed.fr
# postfix:0.0.1

# Requiremnts file should look like this if no custom base_repository 
# postfix:0.0.1

echo "Generate Requirements using $PI_BUILD_SCRIPT_DIR" 

REQUIREMENTS_FILE="requirements"
REQUIREMENTS_TEMPLATE_FILE="$PI_BUILD_SCRIPT_TEMPLATE_DIR/requirements.tpl"
REQUIREMENTS_DEST_FILE="requirements.yml"

cp ../$REQUIREMENTS_TEMPLATE_FILE $REQUIREMENTS_DEST_FILE

LINE_NUMBER=0
REQUIRED_MODULES=0
BASE_REPO=$PI_BUILD_SCRIPT_DEFAULT_MODULE_BASE_REPO
while read -r line
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
			MODULE_NAME="${BASH_REMATCH[1]}" && MODULE_VERSION="${BASH_REMATCH[2]}"
		else
			echo "$line is not a valid requirement"
			exit 1
		fi
		echo "- src: $BASE_REPO$MODULE_NAME/$MODULE_VERSION/$MODULE_NAME-$MODULE_VERSION.tar.gz" >> $REQUIREMENTS_DEST_FILE
		echo "  name: $MODULE_NAME" >> $REQUIREMENTS_DEST_FILE
		echo "  version: $MODULE_VERSION" >> $REQUIREMENTS_DEST_FILE
		((REQUIRED_MODULES++))
	fi
	((LINE_NUMBER++))	
done < "$REQUIREMENTS_FILE"
echo "[ $REQUIRED_MODULES  ] modules required"
