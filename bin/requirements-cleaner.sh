#!/bin/bash

# Requiremnts file should look like this if a custom base_repository is desired
# base-repository=http://gqsdhlqjsdh.qsdqlsdhqsd/dzed.fr
# postfix:0.0.1

# Requiremnts file should look like this if no custom base_repository 
# postfix:0.0.1

REQUIREMENTS_FILE="requirements"

LINE_NUMBER=0
REMOVED_ROLES=0
while read -r line
do 
	re="^(base-repository=)(.*)$"
	if [[ $LINE_NUMBER -eq 0 ]] && [[ "$line" =~ $re ]] ;then
		echo "Using custom base repo is ${BASH_REMATCH[2]}"
	else
		if [[ $LINE_NUMBER -eq 0 ]] && [[ "$line" =~ $re ]] ;
			then echo "Using default base repo "; 
		fi
		echo "Remove $line"
		re="^([^:]+):(.*)$"
		if [[ "$line" =~ $re ]] ;then
			MODULE_NAME="${BASH_REMATCH[1]}" && MODULE_VERSION="${BASH_REMATCH[2]}"
		else
			echo "$line is not a valid requirement"
			exit 1
		fi
		if [ -d roles/$MODULE_NAME ]; then
			rm -rf roles/$MODULE_NAME
			((REMOVED_ROLES++))
		else
			echo "roles/$MODULE_NAME is not present"
		fi
	fi
	((LINE_NUMBER++))	
done < "$REQUIREMENTS_FILE"
echo "[ $REMOVED_ROLES  ] modules removed from roles/"
