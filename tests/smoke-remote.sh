#!/bin/bash

username="smoketest"
password="qwer#1234"
jar_file="original-smokes-1.0-SNAPSHOT.jar"

EAP_VER=$1
RHEL_VER=$2

if [ $EAP_VER == 7 ]
then
  jboss_as_dir="/opt/rh/eap7/root/usr/share/wildfly/"
  log_dir="/opt/rh/eap7/root/usr/share/wildfly/standalone/log /opt/rh/eap7/root/usr/share/wildfly/domain/log"
  eap_standalone="eap7-standalone"
  eap_domain="eap7-domain"
else
  jboss_as_dir="/usr/share/jbossas/"
  log_dir="/usr/share/jbossas/standalone/log /usr/share/jbossas/domain/log"
  eap_standalone="jbossas"
  eap_domain="jbossas-domain"
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
    cleanup
}

function remove_old_logs() {
    service $eap_domain stop
    service $eap_standalone stop
    for dir in $log_dir; do
      rm -rf $dir/*
    done
}

function get_packages() {
    yum -y groupinstall "X Window System" Desktop
    yum -y install firefox

    # workaround to fix https://bugzilla.mozilla.org/show_bug.cgi?id=1376559
    if [ $RHEL_VER == 7 ]
    then
      cd ~/.mozilla/firefox/*.default
      echo "user_pref(\"browser.tabs.remote.autostart.2\", false);" >> prefs.js
    fi
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
    service $eap_standalone start && firefox http://localhost:9990 ; firefox http://localhost:8080/mass-bugzilla-modifier
    service $eap_standalone stop
}

function test_jbossas_domain() {
    service $eap_domain start && firefox http://localhost:9990
    service $eap_domain stop
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

function cleanup() {
    killall firefox
    killall dbus-launch
}

main
