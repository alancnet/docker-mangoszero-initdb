#!/bin/bash

rm -rf /tmp/*
cd /tmp
git clone https://bitbucket.org/mangoszero/content.git
cd content
/bin/sh mysql_import.sh
cd
/bin/sh /update-realm.sh