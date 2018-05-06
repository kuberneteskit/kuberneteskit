#!/usr/bin/env bash

set -e

: ${KUBE_HOST_IMAGE:=kubernetes-base.qcow2}
: ${KUBE_HOST_TYPE:=controlplane}
: ${KUBE_HOST_NAME:=kube-${KUBE_HOST_TYPE}}
: ${KUBE_HOST_METADATA:=}
: ${KUBEADM_CONFIG:=$(cat <<EOF
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
criSocket: /var/run/containerd/containerd.sock
networking:
  podSubnet: 192.168.0.0/16
featureGates:
  CoreDNS: true
kubeProxy:
  config:
    mode: ipvs
EOF
)}
: ${KUBELET_CONFIG:=$(cat <<EOF
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
staticPodPath: /etc/kubernetes/manifests
clusterDomain: cluster.local
clusterDNS:
  - 10.96.0.10
makeIPTablesUtilChains: false
EOF
)}

echo "Creating a ${KUBE_HOST_TYPE} host named: ${KUBE_HOST_NAME}"
echo "Using image: ${KUBE_HOST_IMAGE}"
if [[ -z "${KUBE_HOST_METADATA}" ]]; then
  echo "Using kubeadm config:"
  echo "${KUBEADM_CONFIG}" | sed 's/^/  /'
  echo "Using kubelet config:"
  echo "${KUBELET_CONFIG}" | sed 's/^/  /'
  KUBE_HOST_METADATA=$(cat <<EOF
{
    "kubernetes": {
        "entries": {
            "kubeadm-init": {
                "content": "$(echo "${KUBEADM_CONFIG}" | awk '{printf "%s\\n", $0}')"
            },
            "kubelet-config.yaml": {
                "content": "$(echo "${KUBELET_CONFIG}" | awk '{printf "%s\\n", $0}')"
            }
        }
    }
}
EOF
  )
fi

echo "Using host metadata:"
echo "${KUBE_HOST_METADATA}" | sed 's/^/  /'

state=${KUBE_HOST_NAME}-state

if [ -n "${KUBE_CLEAR_STATE}" ]; then
  rm -rf ${state}
fi

mkdir -p "${state}"

if [ -n "${KUBE_MAC}" ]; then
  echo -n "${KUBE_MAC}" > "${state}/mac-addr"
fi

echo "${KUBE_HOST_METADATA}" > "${state}/metadata.json"

exec linuxkit run -publish 2222:22 -mem 2048 -cpus 2 -disk size=8 -state "${state}" -data-file "${state}/metadata.json" ${KUBE_HOST_IMAGE}
