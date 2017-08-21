#!/bin/bash
#Emmett Underhill July 7 2015
#This is the script that gets run on the vm
#during a smoke testing session. I won't comment
#on what it does exactly because that is outlined
#clearly in the main function

username="smoketest"
password="qwer#1234"
jar_file="original-smokes-1.0-SNAPSHOT.jar"

if [ $1 == 7 ]
  then
    jboss_as_dir="/opt/rh/eap7/root/usr/share/wildfly/"
  else
    jboss_as_dir="/usr/share/jbossas/"
fi

function main() {
    get_packages
    set_X11_auth
    add_jbossas_user
    get_deployment_app
    test_jbossas
    test_jbossas_domain
    print_logs
    kill_firefox
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
    echo '!!!ERRORS!!!'
    cd "/var/log/jbossas"
    echo "Hey, nice job if you're reading this then there aren't any errors!"
    echo "However if there's stuff after this message then there ARE errors"
    echo "in which case I revoke the nice job."
    grep -RHEin "ERROR|FATAL|EXCEPT" . | grep -v "DEBUG"
}

function kill_firefox(){
    killall firefox
}

main
