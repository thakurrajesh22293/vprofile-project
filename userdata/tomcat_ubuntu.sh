#!/bin/bash
set -e

### VARIABLES
TOMCAT_VERSION="8.5.37"
TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
INSTALL_DIR="/usr/local/tomcat8"
APP_REPO="https://github.com/devopshydclub/vprofile-repo.git"
APP_BRANCH="vp-rem"

echo "===== Updating system ====="
sudo apt update -y

echo "===== Installing required packages ====="
sudo apt install -y openjdk-8-jdk git maven wget rsync

echo "===== Verifying Java & Maven ====="
java -version
mvn -version

echo "===== Downloading Tomcat ====="
cd /tmp
rm -rf apache-tomcat*
wget ${TOMCAT_URL} -O tomcat.tar.gz
tar -xzf tomcat.tar.gz

echo "===== Creating Tomcat user ====="
sudo useradd -r -m -U -d ${INSTALL_DIR} -s /usr/sbin/nologin tomcat || true

echo "===== Installing Tomcat ====="
sudo mkdir -p ${INSTALL_DIR}
sudo rsync -av apache-tomcat-${TOMCAT_VERSION}/ ${INSTALL_DIR}/
sudo chown -R tomcat:tomcat ${INSTALL_DIR}

echo "===== Creating Tomcat systemd service ====="
sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOF
[Unit]
Description=Apache Tomcat
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment=JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
Environment=CATALINA_HOME=${INSTALL_DIR}
Environment=CATALINA_BASE=${INSTALL_DIR}
ExecStart=${INSTALL_DIR}/bin/startup.sh
ExecStop=${INSTALL_DIR}/bin/shutdown.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "===== Starting Tomcat ====="
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl restart tomcat

echo "===== Cloning application repository ====="
cd /tmp
rm -rf vprofile-repo
git clone -b ${APP_BRANCH} ${APP_REPO}
cd vprofile-repo

echo "===== Building application with Maven ====="
mvn clean install

echo "===== Deploying application to Tomcat ====="
sudo systemctl stop tomcat
sudo rm -rf ${INSTALL_DIR}/webapps/ROOT*
sudo cp target/vprofile-v2.war ${INSTALL_DIR}/webapps/ROOT.war
sudo chown tomcat:tomcat ${INSTALL_DIR}/webapps/ROOT.war
sudo systemctl start tomcat

echo "===== Deployment completed successfully ====="
echo "Access application at: http://<EC2-PUBLIC-IP>:8080"
