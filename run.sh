#!/bin/bash

BUILD_NAME=$1

if [ $# != 1 ]
then
    echo 'Usage: ./run.sh BUILD_NAME'
    echo 'Example: ./run.sh IVT_RHEL6_EAP64_FRESH1'
    exit
fi

EAP_VER=`echo $BUILD_NAME|awk -F "EAP" '{print $2}'`
EAP_VER_STRIPPED=${EAP_VER:0:1}

RHEL_VER=`echo $BUILD_NAME|awk -F "RHEL" '{print $2}'`
RHEL_VER_STRIPPED=${RHEL_VER:0:1}

read vm ip <<< `python parse.py $BUILD_NAME`

echo "vm name" $vm
echo "vm ip" $ip
echo "eap version" $EAP_VER_STRIPPED
echo "rhel version" $RHEL_VER_STRIPPED

ssh -X root@$ip 'bash -s' < tests/smoke-remote.sh $EAP_VER_STRIPPED $RHEL_VER_STRIPPED
