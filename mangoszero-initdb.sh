#!/bin/bash

MYSQLPASS=$1
REALMIP=$2

#Create appropriate database
mysql -u root -p $MYSQLPASS -h mysql << EOF
CREATE DATABASE mangos_characters;
CREATE DATABASE mangos_realm;
CREATE DATABASE mangos_scripts;
CREATE DATABASE mangos_world;
EOF

rm -rf /tmp/*
cd /tmp
git clone https://bitbucket.org/mangoszero/content.git
cd content

#Populate mysql_info.sh
echo "USER=root" > mysql_info.sh
echo "PASS=$MYSQLPASS" >> mysql_info.sh
echo "HOST=mysql" >> mysql_info.sh
echo "CHARACTER_DATABASE=mangos_characters" >> mysql_info.sh
echo "REALM_DATABASE=mangos_realm" >> mysql_info.sh
echo "SCRIPT_DATABASE=mangos_scripts" >> mysql_info.sh
echo "WORLD_DATABASE=mangos_world" >> mysql_info.sh
echo 'OPTS=' >> mysql_info.sh
echo '[ ! -z "${USER}" ] && OPTS="${OPTS} -u${USER}"' >> mysql_info.sh
echo '[ ! -z "${PASS}" ] && OPTS="${OPTS} -p${PASS}"' >> mysql_info.sh
echo '[ ! -z "${HOST}" ] && OPTS="${OPTS} -h${HOST}"' >> mysql_info.sh
echo '[ ! -z "${SOCK}" ] && OPTS="${OPTS} -S${SOCK}"' >> mysql_info.sh

#Run import
/bin/sh mysql_import.sh

cd

#Update to your IP
/bin/sh /update-realm.sh $MYSQLPASS $REALMIP

#Cleanup
rm -rf /tmp/content