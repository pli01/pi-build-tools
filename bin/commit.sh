#!/bin/bash
message=$1
if [ $# -gt 1 ]; then
  for i in $(seq 2 $#);do
    options+="${!i} "
  done
fi
current_module=`pwd | python -c "import sys;path=sys.stdin.read().split('/');print path[len(path)-1].replace('\n','')"`
git_command="git commit -m \"[$current_module] $message\" $options"
if [ ! -f version ]; then
  echo "The current dir is not a module or service dir"
  echo "You must be in a module or service dir to use this command"
  exit 1
fi
echo $git_command | bash
