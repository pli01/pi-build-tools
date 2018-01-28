#!/bin/bash
version=$1
optional_message=""
if [ $# -gt 1 ]; then
  optional_message=$2
fi

if [ ! -f version ]; then
  echo "The current dir is not a module or service dir"
  echo "You must be in a module or service dir to use this command"
  exit 1
fi

cat <<EOF> version
$version
EOF

current_module=`pwd | python -c "import sys;path=sys.stdin.read().split('/');print path[len(path)-1].replace('\n','')"`
git_command="git add version && git commit -m \"[$current_module] RELEASE $version $optional_message\""
echo $git_command | bash
