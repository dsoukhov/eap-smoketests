#!/bin/bash

sudo dnf install qtwebkit-devel qt-devel -y
sudo ln -s /usr/bin/qmake-qt4 /usr/bin/qmake

sudo pip install beautifulsoup4 dryscrape
