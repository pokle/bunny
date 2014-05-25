#!/usr/bin/env bash

set -e

cd /vagrant/vagrant_data
yum localinstall -y esl-erlang_17.0-1~centos~6_amd64.rpm esl-erlang-compat-R14B-1.el6.noarch.rpm rabbitmq-server-3.3.1-1.noarch.rpm


function set_host() {
	local name=$1
	local ip=$2

	sed -i "/${name}/d" /etc/hosts
	echo "$ip $name" >> /etc/hosts
}

set_host bunny1 192.168.168.168
set_host bunny2 192.168.168.169

echo AIJPLTZUBCSCJFDVJRSC > /var/lib/rabbitmq/.erlang.cookie
chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie
chmod u=rw,go= /var/lib/rabbitmq/.erlang.cookie

service rabbitmq-server stop || echo rabbit was not running

rabbitmq-plugins enable rabbitmq_management

service rabbitmq-server start

#### Do the chk_config thing

if sudo rabbitmqctl list_users | grep bunny; then
	echo user bunny already created
else
	rabbitmqctl add_user bunny wabbit
	rabbitmqctl set_user_tags bunny administrator
fi

set -x
rabbitmqctl set_policy mirror-everything-man ".*" '{"ha-mode":"all"}'
#rabbitmqctl set_policy auto-sync-slaves-man ".*" '{"ha-sync-mode":"automatic"}'
