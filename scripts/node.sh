#!/bin/bash
#
# Setup for Node servers

set -euxo pipefail

config_path="/vagrant/configs"

/bin/bash $config_path/join.sh -v

sudo -i -u vagrant bash << EOF
whoami
mkdir -p /home/vagrant/.kube
sudo cp -i $config_path/config /home/vagrant/.kube/
sudo chown 1000:1000 /home/vagrant/.kube/config
NODENAME=$(hostname -s)
kubectl label node $(hostname -s) node-role.kubernetes.io/worker=worker
EOF

# Create a persistent k8s NFS volume
mkdir -p /srv/k8s-nfs

eval "cat <<EOF
$(curl https://raw.githubusercontent.com/allyunion/vagrant-k8s/main/nfs/pv-nfs-node.yaml 2>/dev/null)
EOF
" 2>/dev/null > /tmp/pv-nfs-node.yaml

kubectl apply -f /tmp/pv-nfs-node.yaml

eval "cat <<EOF
$(https://raw.githubusercontent.com/allyunion/vagrant-k8s/main/nfs/pvc-nfs-node.yaml 2>/dev/null)
EOF
" 2>/dev/null > /tmp/pvc-nfs-node.yaml

kubectl apply -f /tmp/pvc-nfs-node.yaml
