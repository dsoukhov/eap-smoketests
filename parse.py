import sys
import urllib2
import re
import time
from bs4 import BeautifulSoup
import dryscrape

def start():
    if (len(sys.argv) != 2):
        print "Must provide a single url to get the vmip and name."
        sys.exit(1)

    url_start = "http://tovarich2.usersys.redhat.com/jenkins/job/"
    url_end = "/lastSuccessfulBuild"

    url = url_start + sys.argv[1] + url_end

    name = get_name(url)
    ip = get_ip(name)
    print name, ip

def get_name(url):
    soup = BeautifulSoup(urllib2.urlopen(url), "lxml")
    return soup.find('a', {'href': re.compile(r'/jenkins/computer/\.*')}).text

def get_ip(name):
    url ="http://tovarich2.usersys.redhat.com/jenkins/computer/" + name + "/log"
    log_msg = "IP of VM Obtained!"

    session = dryscrape.Session()
    session.visit(url)
    session.wait_for_safe(lambda: session.at_xpath('.//*[@id="out"]'))
    text = session.body()

    for line in text.splitlines():
        if log_msg in line:
            return line.split(" ")[-1]

    raise ValueError('Unable to find ip')

if __name__ == "__main__":
    start()
