#!/bin/bash -ex

TYPE=$1
NAME=$2
DEST=${3:-./$NAME}

usage(){
	echo "$0 TYPE NAME [DEST]"
	echo "TYPE=module|service"
	echo "NAME=Module name"
	echo "[DEST]=optional parameter to specify a path where the role will be built default value is ./$NAME"
}

if [ -z $NAME ]; then echo "Module name is required"; usage; exit 1; fi

case $TYPE in
	"module")
		;;
	"service")
		;;
	*)
		echo "No scaffolder for [$TYPE]"
		usage
		exit 1;
	;;
esac

UPPER_NAME=`echo $NAME | tr '[:lower:]' '[:upper:]'`
echo "Scaffolding a $TYPE named [$NAME] in $DEST"

SCAFFOLD_TEMPLATE="$PI_BUILD_SCRIPT_TEMPLATE_DIR/$TYPE.tpl/"
SCAFFOLD_COMMAND_TEMPLATE="$PI_BUILD_SCRIPT_TEMPLATE_DIR/common.tpl/*"

cp -r $SCAFFOLD_TEMPLATE $DEST
cp -r $SCAFFOLD_COMMAND_TEMPLATE $DEST

#Templating files to inject module name
find $DEST -type f -exec sed -i "s/%${TYPE}_name%/$NAME/g" {} +
find $DEST -type f -exec sed -i "s/%${TYPE}_name%/$NAME/g" {} +
UPPER_TYPE=`echo $TYPE | tr '[:lower:]' '[:upper:]'`
find $DEST -type f -exec sed -i "s/%${UPPER_TYPE}_NAME%/$UPPER_NAME/g" {} +

#Renaming file or directory
find $DEST -iname "*${TYPE}_name*" -exec bash -c 'mv $0 $(echo "$0" | sed -e "s/'"$TYPE"'_name/'"${NAME}"'/g")' '{}' \;

#scaffolding ansible structure
CURRENT_DIR=`pwd`
mkdir -p $DEST/roles && cd $DEST/roles && ansible-galaxy init $NAME --force --offline && cd $CURRENT_DIR
rm $DEST/roles/$NAME/.travis.yml
