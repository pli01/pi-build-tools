#!/bin/bash

DEBUG=1
WORKFILE=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 32`
SEARCHED_DEPENDENCY=$1

cleanFile(){
  if [ -f $WORKFILE ]; then
    rm $WORKFILE
  fi
}

trap cleanFile QUIT INT KILL TERM EXIT

log(){
 if [ "$DEBUG" -eq "0" ];then
   echo $1
 fi
}

for file in `find -name requirements`; do
  log $file
  if grep -q $SEARCHED_DEPENDENCY $file; then
     var=`grep $SEARCHED_DEPENDENCY $file`
     echo -e "`basename $(dirname $file)` -> $var" >> $WORKFILE
  fi
done
cat $WORKFILE | column -t
