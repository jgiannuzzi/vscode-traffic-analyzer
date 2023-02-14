#!/bin/sh

set -x

# if command is sshd, set it up correctly
if [ "${1}" = 'sshd' ]; then
  set -- /usr/sbin/sshd -D -oSetEnv="http_proxy=$http_proxy https_proxy=$https_proxy"
fi

# Fix permissions at every startup
chown vscode:vscode ~vscode

# Setup SSH key
if [ -n "$SSH_KEY_FILE" ]; then
  # Wait for SSH key file to be created
  for i in $(seq 60)
  do
    [ -f "$SSH_KEY_FILE" ] && break
    sleep 1
  done

  mkdir ~vscode/.ssh
  cp "$SSH_KEY_FILE" ~vscode/.ssh/authorized_keys
  chown -R vscode:vscode ~vscode/.ssh
fi

# Setup CA certificate
if [ -n "$CA_FILE" ]; then
  # Wait for CA file to be created
  for i in $(seq 60)
  do
    [ -f "$CA_FILE" ] && break
    sleep 1
  done

  # System
  cp "$CA_FILE" /usr/local/share/ca-certificates/ca.crt
  update-ca-certificates

  # VSCode
  if [ ! -d ~vscode/.pki/nssdb ]; then
    mkdir -p ~vscode/.pki/nssdb
    certutil -N -d sql:/home/vscode/.pki/nssdb --empty-password
  fi
  certutil -A -n ca -t C,, -d sql:/home/vscode/.pki/nssdb -i "$CA_FILE"
  chown -R vscode:vscode ~vscode/.pki
fi

# Configure Apt to use proxy
if [ -n "$http_proxy" ]; then
  cat > /etc/apt/apt.conf.d/proxy.conf <<EOF
Acquire::http::Proxy "$http_proxy";
EOF
fi

exec "$@"
