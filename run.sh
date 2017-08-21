#!/bin/bash

BUILD_NAME=$1
EAP_VER=$2

if [ $# != 2 ]
then
    echo 'Usage: ./run.sh BUILD_NAME EAP_VERSION'
    exit
fi

read vm ip <<< `python parse.py $BUILD_NAME`

echo "vm name" $vm
echo "vm ip" $ip

ssh -X root@$ip 'bash -s' < tests/smoke-remote$EAP_VER.sh
