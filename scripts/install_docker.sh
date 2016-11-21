#!/bin/bash
#
# install_docker.sh
#
# Purpose: Install docker on linux

#default values
TCP_ENABLED_PROP="docker.socket.tcp.enabled"
TCP_ADDRESS_PROP="docker.socket.tcp.address"
GROUP_ENABLED_PROP="docker.group.enabled"
DOCKER_USERS_PROP="docker.group.users"
_default_tcp_enabled="false"
_default_tcp_address="tcp://0.0.0.0:2375"
_default_group_enabled="false"
_default_group_users="cons3rt"

dockerServiceDir=/etc/systemd/system/docker.service.d

timeStamp=$(date "+%Y-%m-%d-%H%M")
logFile=/var/log/cons3rt-install-docker-${timeStamp}.log

function init_props() {
  if [ $(getProperty $TCP_ENABLED_PROP) ]; then
    docker_tcp_enabled=$(getProperty $TCP_ENABLED_PROP)
    logMessage "Docker will be configured to listen over tcp"
  else
    docker_tcp_enabled=$_default_tcp_enabled
    logMessage "Docker will not be configured to listen over tcp"
  fi
  if [ $(getProperty $TCP_ADDRESS_PROP) ]; then
    docker_tcp_address=$(getProperty $TCP_ADDRESS_PROP)
  else
    docker_tcp_address=$_default_tcp_address
  fi

  if [ $(getProperty $GROUP_ENABLED_PROP) ]; then
    docker_group_enabled=$(getProperty $GROUP_ENABLED_PROP)
  else
    docker_group_enabled=$_default_group_enabled
  fi

  if [ $(getProperty $DOCKER_USERS_PROP) ]; then
    docker_users=$(getProperty $DOCKER_USERS_PROP)
  else
    docker_users=$_default_group_users
  fi
}

function install_docker() {
  printf "\nInstalling docker\n"
  yum -y install docker
  printf "DONE\n"
}

function configure_docker() {
  logMessage "Configuring docker daemon to start at boot"
  systemctl enable docker

  mkdir $dockerServiceDir
  touch $dockerServiceDir/docker.conf

  if [ "$docker_tcp_enabled" = "true" ]; then
    logMessage "Docker will be configured to listen over tcp on this address: $docker_tcp_address"
    echo -e "[Service]\nExecStart=\nExecStart=/usr/bin/docker daemon -H unix:///var/run/docker.sock -H $docker_tcp_address" >> $dockerServiceDir/docker.conf
  else
    echo -e "[Service]\nExecStart=\nExecStart=/usr/bin/docker daemon -H unix:///var/run/docker.sock" >> $dockerServiceDir/docker.conf
  fi

  if [ "$docker_group_enabled" = "true" ]; then
    groupadd docker
    if [ "$docker_users" -ne "" ]; then
      if [[ $docker_users == *","* ]]; then
        docker_users_count=$[$(echo $docker_users | grep -o "," | wc -l) + 1]
      else
        docker_users_count=1
      fi
      for (( i=1; i<=$docker_users_count; i++ ))
      do
        current=$(echo $docker_users | cut -d "," -f $i)
        logMessage "Adding user: $current to docker group"
        usermod -a -G docker $current
      done
    fi
  fi

  logMessage "starting docker daemon"
  systemctl daemon-reload
  systemctl start docker
}

function run() {
  init_props 2>&1 | tee ${logFile}
  install_docker 2>&1 | tee ${logFile}
  configure_docker 2>&1 | tee ${logFile}
}

run
