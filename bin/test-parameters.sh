#!/bin/bash

i=0
for var in "$@"
do
    echo "Parameter[$i]=$var"
    ((i++))
done
