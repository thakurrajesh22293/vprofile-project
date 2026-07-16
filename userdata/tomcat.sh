#!/bin/bash

set -e

###############################
# VARIABLES
###############################
TOMCAT_VERSION="9.0.95"
TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"

INSTALL_DIR="/opt/tomcat"

REPO_URL="https://github.com/thakurrajesh22293/vprofile-project.git"
REPO_BRANCH="aws-LiftAndShift"
REPO_DIR="/tmp/vprofile-project"

###############################
# UPDATE SYSTEM
###############################

echo "Updating Ubuntu..."

sudo apt update
sudo apt upgrade -y

###############################
# INSTALL PACKAGES
###############################

echo "Installing required packages..."

sudo apt install -y \
openjdk-17-jdk \
git \
maven \
wget \
curl \
unzip \
rsync

###############################
# VERIFY JAVA
###############################

java -version
mvn -version

###############################
# CREATE TOMCAT USER
###############################

sudo useradd -r -m -U -d ${INSTALL_DIR} -s /usr/sbin/nologin tomcat || true

###############################
# DOWNLOAD TOMCAT
###############################

cd /tmp

rm -rf apache-tomcat*

wget ${TOMCAT_URL} -O tomcat.tar.gz

tar -xzf tomcat.tar.gz

###############################
# INSTALL TOMCAT
###############################

sudo mkdir -p ${INSTALL_DIR}

sudo rsync -av apache-tomcat-${TOMCAT_VERSION}/ ${INSTALL_DIR}/

sudo chown -R tomcat:tomcat ${INSTALL_DIR}

sudo chmod +x ${INSTALL_DIR}/bin/*.sh

###############################
# CREATE SYSTEMD SERVICE
###############################

sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOF
[Unit]
Description=Apache Tomcat
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment=JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
Environment=CATALINA_HOME=${INSTALL_DIR}
Environment=CATALINA_BASE=${INSTALL_DIR}
Environment=CATALINA_PID=${INSTALL_DIR}/temp/tomcat.pid

ExecStart=${INSTALL_DIR}/bin/startup.sh
ExecStop=${INSTALL_DIR}/bin/shutdown.sh

Restart=always

[Install]
WantedBy=multi-user.target
EOF

###############################
# START TOMCAT
###############################

sudo systemctl daemon-reload

sudo systemctl enable tomcat

sudo systemctl restart tomcat

###############################
# CLONE PROJECT
###############################

cd /tmp

rm -rf ${REPO_DIR}

git clone -b ${REPO_BRANCH} ${REPO_URL}

cd ${REPO_DIR}

###############################
# BUILD APPLICATION
###############################

mvn clean install -DskipTests

###############################
# DEPLOY WAR
###############################

sudo systemctl stop tomcat

sudo rm -rf ${INSTALL_DIR}/webapps/*

WAR_FILE=$(find target -name "*.war" | head -n 1)

sudo cp "$WAR_FILE" ${INSTALL_DIR}/webapps/ROOT.war

sudo chown tomcat:tomcat ${INSTALL_DIR}/webapps/ROOT.war

sudo systemctl start tomcat

###############################
# VERIFY
###############################

echo
echo "========================================"
echo "Deployment Successful"
echo "========================================"

echo "Tomcat Status:"
sudo systemctl --no-pager status tomcat

echo
echo "Application URL:"
echo "http://<YOUR-EC2-PUBLIC-IP>:8080"
