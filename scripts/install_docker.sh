#!/bin/bash
#
# install_docker.sh
#
# Purpose: Install docker on linux

#default values
TCP_ENABLED_PROP="docker.socket.tcp.enabled"
TCP_ADDRESS_PROP="docker.socket.tcp.address"
_default_tcp_enabled=false
_default_tcp_address="tcp://0.0.0.0:2375"

dockerServiceDir=/etc/systemd/system/docker.service.d

timeStamp=$(date "+%Y-%m-%d-%H%M")
logFile=/var/log/cons3rt-install-docker-${timeStamp}.log

function install_docker() {
  printf "\nInstalling docker\n"
  yum -y install docker
  printf "DONE\n"
}

function configure_docker() {
  logMessage "Configuring docker daemon to start at boot"
  systemctl enable docker

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
  mkdir $dockerServiceDir
  touch $dockerServiceDir/docker.conf

  if [ "$docker_tcp_enabled" = "true" ]; then
    logMessage "Docker will be configured to listen over tcp on this address: $docker_tcp_address"
    echo -e "[Service]\nExecStart=/usr/bin/dockerd -H unix:///var/run/docker.sock -H $docker_tcp_address" >> $dockerServiceDir/docker.conf
  else
    echo -e "[Service]\nExecStart=/usr/bin/dockerd -H unix:///var/run/docker.sock" >> $dockerServiceDir/docker.conf
  fi

  logMessage "starting docker daemon"
  systemctl daemon-reload
  systemctl start docker
}

install_docker 2>&1 | tee ${logFile}
configure_docker 2>&1 | tee ${logFile}
