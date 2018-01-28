#!/bin/bash

DIRECTORY_LOG=$1
NAME_FILE_LOG=$2

if [ "$1" == "" -o "$2" == "" ];then
echo "Usage: $0 <DIRECTORY_LOG> <NAME_FILE_LOG>\n - DIRECTORY: path du repertoire de log\n - NAME_FILE_LOG: nom du fichier de log"
  exit 1
fi

echo "Check ansible script do not contains any WARNINGS"
n=0
test_result=1;
if grep "WARNING" $DIRECTORY_LOG/$NAME_FILE_LOG > /dev/null ; then
	n=`grep -c "WARNING" $DIRECTORY_LOG/$NAME_FILE_LOG`
        echo "Il y'a $n WARNING"
	echo "---------LISTE---DES----WARNING---------"
	grep WARNING $DIRECTORY_LOG/$NAME_FILE_LOG
	echo "-------- FIN----LISTE----WARNING--------"
else
        echo "Il n'y a pas de WARNING"
	test_result=0;
fi
exit $test_result
