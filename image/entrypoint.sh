#!/bin/bash

if [ "${INLETS_CLIENT_ID}" = "" ]; then
  echo "Please Config Env: INLETS_CLIENT_ID"
  exit -1
fi
if [ "${INLETS_CLIENT_SECRET}" = "" ]; then
  echo "Please Config Env: INLETS_CLIENT_SECRET"
  exit -1
fi

if [ "${INLETS_PORT}" = "" ]; then
  echo "Please Config Env: INLETS_PORT"
  exit -1
fi

# echo "Start Server ..."
# Fix run `docker ps` with sudo
if [ -f /var/run/docker.sock ]; then
  sudo chown $USER /var/run/docker.sock
fi

# echo "Start OpenSSH Server ..."
sudo service ssh restart

if [ -f /etc/init.d/rsyslog ]; then
  # Reference: https://stackoverflow.com/questions/22526016/docker-container-sshd-logs
  # echo "Start Rsyslog(/var/log/auth.log) ..."
  if [ -f "/run/rsyslogd.pid" ]; then
    sudo rm -rf /run/rsyslogd.pid
  fi

  sudo service rsyslog restart
fi

if [ -f /etc/init.d/fail2ban ]; then
  # Reference: https://stackoverflow.com/questions/22526016/docker-container-sshd-logs
  # echo "Start Fail2ban(/var/log/fail2ban.log) ..."
  if [ -f "/var/run/fail2ban/fail2ban.sock" ]; then
    sudo rm -rf /var/run/fail2ban/fail2ban.sock
  fi

  sudo service fail2ban restart
fi

# Change Mirror
# bash /build/scripts/change-mirrors.sh

echo ""
echo "##################################"
echo "Now, Everything is Ready ..."
echo "##################################"
echo ""

# Make it Front
# sleep infinity

# echo "Start Inlets Service ..."
# Nodejs
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
inlets client --credentials $INLETS_CLIENT_ID:$INLETS_CLIENT_SECRET tcp 22 -p ${INLETS_PORT}

# @TODO avoid restart too quick
sleep 3