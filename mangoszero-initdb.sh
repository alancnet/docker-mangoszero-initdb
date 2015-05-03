#!/bin/bash

MYSQLPASS=$1
REALMIP=$2

#Create appropriate database
mysql -u root -p$MYSQLPASS -h mysql << EOF
CREATE DATABASE realmd DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE DATABASE mangos DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE DATABASE characters DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE DATABASE scriptdev2 DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER 'mangos'@'%' IDENTIFIED BY 'mangos';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, LOCK TABLES ON realmd.* TO 'mangos'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, LOCK TABLES ON mangos.* TO 'mangos'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, LOCK TABLES ON characters.* TO 'mangos'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, LOCK TABLES ON scriptdev2.* TO 'mangos'@'%';
EOF

rm -rf /tmp/*
cd /tmp
git clone https://bitbucket.org/mangoszero/content.git
cd content
chmod +x mysql_import.sh

#Populate mysql_info.sh
echo "USER=mangos" > mysql_info.sh
echo "PASS=mangos" >> mysql_info.sh
echo "HOST=mysql" >> mysql_info.sh
echo "CHARACTER_DATABASE=characters" >> mysql_info.sh
echo "REALM_DATABASE=realmd" >> mysql_info.sh
echo "SCRIPT_DATABASE=scriptdev2" >> mysql_info.sh
echo "WORLD_DATABASE=mangos" >> mysql_info.sh
echo 'OPTS=' >> mysql_info.sh
echo '[ ! -z "${USER}" ] && OPTS="${OPTS} -u${USER}"' >> mysql_info.sh
echo '[ ! -z "${PASS}" ] && OPTS="${OPTS} -p${PASS}"' >> mysql_info.sh
echo '[ ! -z "${HOST}" ] && OPTS="${OPTS} -h${HOST}"' >> mysql_info.sh
echo '[ ! -z "${SOCK}" ] && OPTS="${OPTS} -S${SOCK}"' >> mysql_info.sh

#Run import
./mysql_import.sh

cd /tmp
git clone https://bitbucket.org/mangoszero/scripts.git
cd scripts/sql
mysql -u mangos -pmangos scriptdev2 < scriptdev2_script_full.sql

#Update to your IP
mysql -u mangos -pmangos -h mysql << EOF
USE realmd
UPDATE realmlist
SET address = "$REALMIP"
WHERE realmlist.id = 1;
EOF

#Cleanup
rm -rf /tmp/*