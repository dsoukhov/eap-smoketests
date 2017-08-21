#!/bin/bash

BUILD_NAME=$1

if [ $# != 1 ]
then
    echo 'Usage: ./run.sh BUILD_NAME'
    exit
fi

EAP_VER=`echo $BUILD_NAME|awk -F "EAP" '{print $2}'`
EAP_VER_STRIPPED=${EAP_VER:0:1}

read vm ip <<< `python parse.py $BUILD_NAME`

echo "vm name" $vm
echo "vm ip" $ip
echo "eap version" $EAP_VER_STRIPPED

ssh -X root@$ip 'bash -s' < tests/smoke-remote.sh $EAP_VER_STRIPPED
