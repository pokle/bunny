#!/usr/bin/env bash

set -e

function install_rpm() {
  local name=$1
  local file=$2
  if rpm -q $name; then
    echo rpm $1 already installed
  else
    yum localinstall -y $file
  fi
}

function set_host() {
	local name=$1
	local ip=$2

	sed -i "/${name}/d" /etc/hosts
	echo "$ip $name" >> /etc/hosts
}


# Packages
install_rpm esl-erlang_17.0-1 /vagrant/vagrant_data/esl-erlang_17.0-1~centos~6_amd64.rpm
install_rpm esl-erlang-compat /vagrant/vagrant_data/esl-erlang-compat-R14B-1.el6.noarch.rpm
install_rpm rabbitmq-server-3.3.1 /vagrant/vagrant_data/rabbitmq-server-3.3.1-1.noarch.rpm


# RabbitMQ needs hostname to ip mappings. The hostname of the server must match this
set_host bunny1 192.168.168.168
set_host bunny2 192.168.168.169

# Unique cluster cookie
echo AIJPLTZUBCSCJFDVJRSC > /var/lib/rabbitmq/.erlang.cookie
chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie
chmod u=rw,go= /var/lib/rabbitmq/.erlang.cookie


if rabbitmq-plugins list | grep '^\[E\] rabbitmq_management'; then
  echo rabbitmq_management plugin is on - great.
else
  rabbitmq-plugins enable rabbitmq_management
  service rabbitmq-server stop
fi


service rabbitmq-server start

#### Do the chk_config thing
sudo /sbin/chkconfig  rabbitmq-server on

if sudo rabbitmqctl list_users | grep bunny; then
	echo user bunny already created
else
	rabbitmqctl add_user bunny wabbit
	rabbitmqctl set_user_tags bunny administrator
fi

if sudo rabbitmqctl list_policies | grep mirror-everything-man; then
  echo cluster policies already installed
else
  sudo rabbitmqctl set_policy mirror-everything-man ".*" '{"ha-mode":"all"}'
fi

#rabbitmqctl set_policy auto-sync-slaves-man ".*" '{"ha-sync-mode":"automatic"}'
