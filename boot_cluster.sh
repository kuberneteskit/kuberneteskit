#!/usr/bin/env bash

set -e

: ${KUBE_CP_COUNT:=1}
: ${KUBE_NODE_COUNT:=0}

if [[ "${KUBE_CP_COUNT}" > 1 ]]; then
  echo "HA Control Plane not supported."
  exit 1
fi

echo "Booting the control plane instance..."
./boot.sh &> kube-controlplane-state/console.out &

for node_num in $(seq 1 ${KUBE_NODE_COUNT}); do
  echo "Booting node instance ${node_num}..."
  node_name=kube-node-${node_num}
  mkdir -p ${node_name}-state
  KUBE_NODE_TYPE=node KUBE_NODE_NAME=${node_name} ./boot.sh &> ${node_name}-state/console.out &
done