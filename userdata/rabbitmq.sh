#!/bin/bash

set -e

echo "===== Updating system ====="

sudo apt update
sudo apt upgrade -y

echo "===== Installing prerequisites ====="

sudo apt install -y curl gnupg apt-transport-https lsb-release ca-certificates

echo "===== Installing Erlang ====="

sudo apt install -y erlang

echo "===== Installing RabbitMQ ====="

sudo apt install -y rabbitmq-server

echo "===== Enabling RabbitMQ ====="

sudo systemctl enable rabbitmq-server
sudo systemctl start rabbitmq-server

echo "===== Configuring RabbitMQ ====="

sudo tee /etc/rabbitmq/rabbitmq.conf >/dev/null <<EOF
loopback_users.none = true
EOF

sudo systemctl restart rabbitmq-server

echo "===== Creating user ====="

sudo rabbitmqctl add_user test test || true
sudo rabbitmqctl set_user_tags test administrator
sudo rabbitmqctl set_permissions -p / test ".*" ".*" ".*"

echo "===== Enabling Management Plugin ====="

sudo rabbitmq-plugins enable rabbitmq_management

sudo systemctl restart rabbitmq-server

echo "======================================"
echo "RabbitMQ Installed Successfully"
echo "======================================"
echo "Management UI:"
echo "http://<SERVER-IP>:15672"
echo
echo "Username: test"
echo "Password: test"
