#!/bin/bash

DEBUG=1
GREEN='\033[0;32m'
NC='\033[0m' # No Color

log(){
  if [ $DEBUG -eq 0 ];then
    echo $1;
  fi
}

if [ "$#" -gt 0 ]; then
  log "target is defined"
  FILE_PARAMATER=$1
  export SHIFT=0
  if [ "$#" -eq 2 ]; then
    export SHIFT=`echo "$(( 2 + 2 * $2))"`
  fi
  spaces=`printf %"$SHIFT"s`
  if [[ "$FILE_PARAMATER" =~ .*gz ]];then
    log "ZCATING $FILE_PARAMATER"
    [ "$SHIFT" -eq "0" ] && echo -e "$GREEN$FILE_PARAMATER$NC"
    tar -xOf $FILE_PARAMATER ./requirements | sed "s/^/$spaces/g" | column -t -s$':'
  else
    if [ -f $FILE_PARAMATER ]; then
      log "READING $FILE_PARAMATER"
      [ "$SHIFT" -eq "0" ] && echo -e "$GREEN$FILE_PARAMATER$NC"
      cat $FILE_PARAMATER | sed "s/^/$spaces/g" | column -t -s$':'
    else
      for f in `find $FILE_PARAMATER -name "requirements"`;do
        log "[$f] requirements"
        [ "$SHIFT" -eq "0" ] && echo -e "$GREEN$f$NC"
        cat $f | sed "s/^/$spaces/g" | column -t -s$':'
      done
    fi
  fi
fi
