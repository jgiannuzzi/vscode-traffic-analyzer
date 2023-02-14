#!/bin/sh

set -x

# Cleanup desktop
rm -rf ~/Desktop/Uploads ~/Desktop/Downloads ~/Uploads

# Setup CA certificate
if [ -n "$CA_FILE" ]; then
  # Wait for CA file to be created
  for i in $(seq 60)
  do
    [ -f "$CA_FILE" ] && break
    sleep 1
  done

  # System
  sudo cp "$CA_FILE" /usr/local/share/ca-certificates/ca.crt
  sudo update-ca-certificates

  # VSCode
  if [ ! -d ~/.pki/nssdb ]; then
    mkdir -p ~/.pki/nssdb
    certutil -N -d sql:$HOME/.pki/nssdb --empty-password
  fi
  certutil -A -n ca -t C,, -d sql:$HOME/.pki/nssdb -i "$CA_FILE"

  # Firefox
  jq ".policies.Certificates.Install = [\"$CA_FILE\"]" --null-input | sudo tee /usr/lib/firefox/distribution/policies.json >/dev/null
fi

# Configure Apt to use proxy
if [ -n "$http_proxy" ]; then
  sudo tee /etc/apt/apt.conf.d/proxy.conf >/dev/null <<EOF
Acquire::http::Proxy "$http_proxy";
EOF
fi

if [ ! -f ~/.ssh/id_rsa.pub ]; then
  [ -d ~/.ssh ] || mkdir ~/.ssh
  sudo chown -R $(id -u):$(id -g) ~/.ssh
  chmod 700 ~/.ssh
  ssh-keygen -f ~/.ssh/id_rsa -N ''
fi

if [ ! -f ~/.ssh/config ]; then
  cat > ~/.ssh/config <<EOF
Host server
  Hostname server
  StrictHostKeyChecking no
EOF
fi

sleep infinity
