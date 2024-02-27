#!/bin/bash
#
# Setup for Control Plane (Master) servers

set -euxo pipefail

export NODENAME=$(hostname -s)

sudo kubeadm config images pull

echo "Preflight Check Passed: Downloaded All Required Images"

#sudo kubeadm init --apiserver-advertise-address=$CONTROL_IP --apiserver-cert-extra-sans=$CONTROL_IP --pod-network-cidr=$POD_CIDR --service-cidr=$SERVICE_CIDR --node-name "$NODENAME" --ignore-preflight-errors Swap
export CONTROL_IP=$CONTROL_IP
export POD_CIDR=$POD_CIDR
export SERVICE_CIDR=$SERVICE_CIDR
sudo -E /usr/bin/envsubst < /tmp/kubeconfig_template.yaml > /tmp/kubeconfig.yaml

sudo kubeadm init --config /tmp/kubeconfig.yaml --ignore-preflight-errors Swap

mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config

# Save Configs to shared /Vagrant location

# For Vagrant re-runs, check if there is existing configs in the location and delete it for saving new configuration.

config_path="/vagrant/configs"

if [ -d $config_path ]; then
  rm -f $config_path/*
else
  mkdir -p $config_path
fi

cp -i /etc/kubernetes/admin.conf $config_path/config
touch $config_path/join.sh
chmod +x $config_path/join.sh

kubeadm token create --print-join-command > $config_path/join.sh

# Install Calico Network Plugin

curl https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/calico.yaml -O

kubectl apply -f calico.yaml

sudo -i -u vagrant bash << EOF
whoami
mkdir -p /home/vagrant/.kube
sudo cp -i $config_path/config /home/vagrant/.kube/
sudo chown 1000:1000 /home/vagrant/.kube/config
EOF

# Install Metrics Server

kubectl apply -f https://raw.githubusercontent.com/techiescamp/kubeadm-scripts/main/manifests/metrics-server.yaml
