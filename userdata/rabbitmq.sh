#!/bin/bash
set -e

echo "===== Updating system ====="
sudo dnf update -y

echo "===== Fixing minimal package conflicts ====="
sudo dnf install -y curl gnupg2 wget --allowerasing

echo "===== Adding Erlang repository ====="
sudo tee /etc/yum.repos.d/rabbitmq-erlang.repo > /dev/null <<EOF
[rabbitmq-erlang]
name=RabbitMQ Erlang
baseurl=https://packagecloud.io/rabbitmq/erlang/el/9/x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
sslverify=1
EOF

echo "===== Installing Erlang ====="
sudo dnf install -y erlang

echo "===== Adding RabbitMQ repository ====="
sudo tee /etc/yum.repos.d/rabbitmq.repo > /dev/null <<EOF
[rabbitmq]
name=RabbitMQ Server
baseurl=https://packagecloud.io/rabbitmq/rabbitmq-server/el/9/x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
sslverify=1
EOF

echo "===== Installing RabbitMQ ====="
sudo dnf install -y rabbitmq-server

echo "===== Enabling & starting RabbitMQ ====="
sudo systemctl enable rabbitmq-server
sudo systemctl start rabbitmq-server

echo "===== Configuring RabbitMQ ====="
sudo mkdir -p /etc/rabbitmq
sudo tee /etc/rabbitmq/rabbitmq.conf > /dev/null <<EOF
loopback_users.none = true
EOF

sudo systemctl restart rabbitmq-server

echo "===== Creating RabbitMQ user ====="
sudo rabbitmqctl add_user test test || true
sudo rabbitmqctl set_user_tags test administrator
sudo rabbitmqctl set_permissions -p / test ".*" ".*" ".*"

echo "===== Enabling RabbitMQ Management UI ====="
sudo rabbitmq-plugins enable rabbitmq_management

echo "===== RabbitMQ installation completed successfully ====="
echo "UI: http://<EC2-PUBLIC-IP>:15672"
echo "User: test | Password: test"
