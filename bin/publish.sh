#!/bin/bash
# TARGET_REPOSITORY env variable contains name of the repo

MODULE_NAME=$1
RELEASE_VERSION=$2
RELEASE_FILE_NAME=$3
RELEASE_FILE_LOCATION=$4

usage() {
  echo "Requires some env variables to be setted : TARGET_REPOSITORY REPOSITORY_USERNAME REPOSITORY_PASSWORD"
  echo "usage is : $0 MODULE_NAME RELEASE_VERSION RELEASE_FILE_NAME RELEASE_FILE_LOCATION"
  exit 1
}

NETRC_FILENAME=.netrc-file
GITPASS_FILENAME=`pwd`/pass.sh

createNetrcFile() {
cat << EOF > $NETRC_FILENAME
machine $PI_BUILD_SCRIPT_DML_FDQN
login $REPOSITORY_USERNAME
password $REPOSITORY_PASSWORD
EOF
}

createPassFile() {
cat << EOF > $GITPASS_FILENAME
#!/bin/bash
re=".*Password.*"
if [[ "\$1" =~ \$re ]]; then
  echo "$REPOSITORY_PASSWORD"
else
  echo "$REPOSITORY_USERNAME"
fi
EOF
chmod +x $GITPASS_FILENAME
}

bumpVersion() {
current_version=`cat version`
current_first=`echo "$current_version" | awk -F . '{ print $1 }'`
current_second=`echo "$current_version" | awk -F . '{ print $2 }'`
current_third=`echo "$current_version" | awk -F . '{ print $3 }'`
(( current_second ++ ))
new_version=$current_first"."$current_second".0-SNAPSHOT"
echo $new_version > version
}

function upload_file () {
    echo "# upload $1 $2 $3"
    case $3 in
        file://*)
            echo "#File mode"
            dir=${3#file://}
            mkdir -p $(dirname $dir)
                curl -i --insecure --netrc-file $1 --upload-file $2 $3
            ;;
        http*)
                curl -i --insecure --netrc-file $1 --upload-file $2 $3 | grep "HTTP/1.1 201"
            ;;
    esac
}

if [ -z $TARGET_REPOSITORY ];then echo "TARGET_REPOSITORY undefined" ; usage;fi
if [ -z $REPOSITORY_USERNAME ];then echo "REPOSITORY_USERNAME undefined" ; usage;fi
if [ -z $REPOSITORY_PASSWORD ];then echo "REPOSITORY_PASSWORD undefined" ; usage;fi

if [ $# -ne 4 ];then usage;fi

TARGET_URL=$PI_BUILD_SCRIPT_DML_REPOSITORY_URL/$TARGET_REPOSITORY/$MODULE_NAME/$RELEASE_VERSION/$RELEASE_FILE_NAME	
RELEASE_FILE_NAME_LATEST=$(echo $RELEASE_FILE_NAME | sed "s/$RELEASE_VERSION/latest/")
TARGET_URL_LATEST="$PI_BUILD_SCRIPT_DML_REPOSITORY_URL/$TARGET_REPOSITORY/$MODULE_NAME/latest/$RELEASE_FILE_NAME_LATEST"
RELEASE_FILE_PATH=$RELEASE_FILE_LOCATION/$RELEASE_FILE_NAME
CURRENT_DIR=`pwd`

createNetrcFile

curl --insecure --head -i $TARGET_URL 2> /dev/null| grep "HTTP/1.1 404"
PUBLISH_REQUIRED=$?
IS_SNAPSHOT=1

re="^.*-SNAPSHOT$"
if [[ "$RELEASE_VERSION" =~ $re ]]; then
        echo "Force publishing of the SNAPSHOT VERSION : $RELEASE_VERSION"
        PUBLISH_REQUIRED=0
	IS_SNAPSHOT=0
fi

if [ "0" -eq $PUBLISH_REQUIRED ]; then
        echo "CREATING MD5 SUM file for $RELEASE_FILE_NAME"
        cd $RELEASE_FILE_LOCATION && md5sum $RELEASE_FILE_NAME > $CURRENT_DIR/$RELEASE_FILE_NAME".md5" && cd $CURRENT_DIR
        echo -e "PUBLISHING $RELEASE_FILE_PATH AT $TARGET_URL"
        upload_file $NETRC_FILENAME $RELEASE_FILE_PATH $TARGET_URL
        PUBLISH_STATUS=$?
        if [ "0" -ne $PUBLISH_STATUS ]; then
                echo -e "FAIL TO PUBLISH $RELEASE_FILE_PATH AT $TARGET_URL"
                exit 1
        fi
	if [ "1" -eq $IS_SNAPSHOT ]; then
	        upload_file $NETRC_FILENAME $RELEASE_FILE_PATH $TARGET_URL_LATEST
	fi

        upload_file $NETRC_FILENAME $RELEASE_FILE_NAME".md5" $TARGET_URL".md5"
        PUBLISH_STATUS=$?
        if [ "0" -ne $PUBLISH_STATUS ]; then
                echo -e "WARN : FAIL TO PUBLISH $RELEASE_FILE_NAME.md5 AT $TARGET_URL.md5"
        fi
	if [ "1" -eq $IS_SNAPSHOT ]; then
		upload_file $NETRC_FILENAME $RELEASE_FILE_PATH".md5" $TARGET_URL_LATEST".md5"
	fi

        rm $RELEASE_FILE_NAME".md5"
        echo -e "$RELEASE_FILE_PATH PUBLISHED AT $TARGET_URL"
	TAG="$MODULE_NAME/$RELEASE_VERSION"
	echo "*************** TAGING in repository as $TAG   *********************"
	createPassFile
	git checkout master
	git tag -f -a "$TAG" -m ""
	export GIT_ASKPASS=$GITPASS_FILENAME
	git push origin "$TAG" -f
	if [ "1" -eq $IS_SNAPSHOT ]; then
		echo " ********************* BUMPING VERSION TO PUT IT BACK TO SNAPSHOT  ************ "
		bumpVersion
		new_version=`cat version`
		echo "Changing to new version [$new_version]"
		git commit -m "post release $MODULE_NAME [ $RELEASE_VERSION -> $new_version ]" version
		git push
		echo -e "Bonjour, \n$MODULE_NAME est release de [ $RELEASE_VERSION -> $new_version ] merci de rebaser votre depot" | mail -s "[Jenkins CI] Release $MODULE_NAME/$RELEASE_VERSION" $MAIL_BUILD
	fi
	rm $GITPASS_FILENAME
	unset GIT_ASKPASS
else
        echo -e "$RELEASE_FILE_PATH IS ALREADY PUBLISHED AT $TARGET_URL"
	rm $NETRC_FILENAME
	exit 1
fi
rm $NETRC_FILENAME
