#!/bin/bash

kubectl config set-cluster vagrant --server="https://10.0.0.10:6443"
kubectl config set-credentials admin-user --token=$(vagrant ssh master -c "sudo kubectl -n kubernetes-dashboard get secret/admin-user -o go-template='{{.data.token | base64decode }}'")
kubectl config set-context vagrant --user=admin-user --cluster=vagrant
kubectl config use-context vagrant
