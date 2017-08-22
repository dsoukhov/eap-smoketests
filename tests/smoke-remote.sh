#!/bin/bash

username="smoketest"
password="qwer#1234"
jar_file="original-smokes-1.0-SNAPSHOT.jar"

if [ $1 == 7 ]
  then
    jboss_as_dir="/opt/rh/eap7/root/usr/share/wildfly/"
    log_dir="/opt/rh/eap7/root/usr/share/wildfly/standalone/log /opt/rh/eap7/root/usr/share/wildfly/domain/log"
  else
    jboss_as_dir="/usr/share/jbossas/"
    log_dir="/usr/share/jbossas/standalone/log /usr/share/jbossas/domain/log"
fi

function main() {
   remove_old_logs
   get_packages
   set_X11_auth
   add_jbossas_user
   get_deployment_app
   test_jbossas
   test_jbossas_domain
   print_logs
}

function remove_old_logs() {
    service jbossas stop
    for dir in $log_dir; do
      rm -rf $dir/*
    done
}

function get_packages() {
    yum -y groupinstall "X Window System" Desktop
    yum -y install firefox
}

function set_X11_auth(){
    xauth merge /root/.Xauthority
}

function add_jbossas_user() {
    $jboss_as_dir"bin/add-user.sh" $username $password
}

function get_deployment_app() {
    wget s01.yyz.redhat.com/dcheung/mass-bugzilla-modifier.war -O $jboss_as_dir"standalone/deployments/mass-bugzilla-modifier.war"
}

function setup_hosts_file() {
    echo 127.0.0.1 localhost localhost.localdomain > /etc/hosts
}

function test_jbossas() {
    service jbossas start && firefox http://localhost:9990 ; firefox http://localhost:8080/mass-bugzilla-modifier
    service jbossas stop
}
function test_jbossas_domain() {
    service jbossas-domain start && firefox http://localhost:9990
    service jbossas-domain stop
}
function print_logs() {
    logs=`grep -RHEin "ERROR|FATAL|EXCEPT" $log_dir | grep -v "DEBUG"`

    if [ -z "$logs" ]
      then
        echo "No errors found!"
      else
        echo "!!!!ERRORS!!!!"
        echo $logs
    fi
}
main
