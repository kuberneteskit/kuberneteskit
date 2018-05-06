#!/bin/sh

if [[ -f /run/config/kubernetes/kubeadm-init ]]; then
  kubeadm init -- config /run/config/kubernetes/kubeadm-init --ignore-preflight-errors=FileExisting-iptables
  export KUBECONFIG=/etc/kubernetes/admin.conf
  kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml
fi