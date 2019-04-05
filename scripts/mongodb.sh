#!/bin/bash
set -e

echo "**************************************************************"
echo "*               Installing MongoDB Server                    *"
echo "**************************************************************"

echo "Installing MongoDB"
apt update
apt install -y pwgen \
               mongodb

echo "Creating directories"
mkdir -p /home/appbox/mongodb/data
mkdir -p /home/appbox/logs/mongodb
mkdir -p /home/appbox/config/mongodb

echo "Creating logfile"
touch /home/appbox/logs/mongodb/mongod.log

echo "Setting permissions"
chown -R appbox:appbox /home/appbox

echo "Defining default variables"
MONGO_PORT=${MONGO_PORT:-"27017"}
MONGO_LOGFILE=${MONGO_LOGFILE:-"/home/appbox/logs/mongodb/mongod.log"}
MONGO_USER=${MONGO_USER:-"mongo"}
MONGO_HOME=${MONGO_HOME:-"/home/appbox/mongodb/data"}
MONGO_LOGLEVEL=${MONGO_LOGLEVEL:-"v"}
DB_USER=${DB_USER:-"mongoUser"}
DB_PASS=${DB_PASS:-"mongoPass"}

echo "Start MongoDB without authentication"
mongod \
  --port ${MONGO_PORT} \
  --dbpath ${MONGO_HOME} \
  --logpath ${MONGO_LOGFILE} \
  --logappend \
  -${MONGO_LOGLEVEL} &

sleep 10

echo "Adding the MongoDB User"
mongo admin << EOF
use admin
db.createUser(
{
    user: "${DB_USER}",
    pwd: "${DB_PASS}",
    roles: [ "userAdminAnyDatabase",
             "dbAdminAnyDatabase",
             "readWriteAnyDatabase" ]
})
EOF

echo "Saving config file"
cat << EOF >> /home/appbox/config/mongodb/mongod.conf
security:
  authorization: enabled
EOF

sleep 5

echo "Killing MongoDB"
pkill -9 mongod

# Setup MongoDB Daemon
echo "Setting up MongoDB Daemon"
mkdir -p /etc/service/mongodb
cat << EOF >> /etc/service/mongodb/run
#!/bin/sh
exec /usr/bin/mongod --config /home/appbox/config/mongodb/mongod.conf --port ${MONGO_PORT} --dbpath ${MONGO_HOME} --logpath ${MONGO_LOGFILE} --logappend -${MONGO_LOGLEVEL} --smallfiles
EOF
chmod +x /etc/service/mongodb/run

echo "Finished installing MongoDB"