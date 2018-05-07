#!/usr/bin/env bash

set -e

: ${KUBE_HOST_IMAGE:=kubernetes-base}
: ${KUBE_HOST_TYPE:=controlplane}
: ${KUBE_HOST_NAME:=kube-${KUBE_HOST_TYPE}}
: ${KUBE_HOST_METADATA:=}
: ${KUBEADM_INIT_CONFIG:=$(cat <<EOF
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
  echo "Using kubelet config:"
  echo "${KUBELET_CONFIG}" | sed 's/^/  /'

  if [[ "${KUBE_HOST_TYPE}" == "controlplane" ]]; then
    echo "Using kubeadm init config:"
    echo "${KUBEADM_INIT_CONFIG}" | sed 's/^/  /'

    KUBE_HOST_METADATA=$(cat <<EOF
{
    "kubernetes": {
        "entries": {
            "kubeadm-init": {
                "content": "$(echo "${KUBEADM_INIT_CONFIG}" | awk '{printf "%s\\n", $0}')"
            },
            "kubelet-config.yaml": {
                "content": "$(echo "${KUBELET_CONFIG}" | awk '{printf "%s\\n", $0}')"
            }
        }
    }
}
EOF
    )
  else
    KUBE_HOST_METADATA=$(cat <<EOF
{
    "kubernetes": {
        "entries": {
            "kubelet-config.yaml": {
                "content": "$(echo "${KUBELET_CONFIG}" | awk '{printf "%s\\n", $0}')"
            }
        }
    }
}
EOF
    )
  fi
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


kernel_path="${KUBE_HOST_IMAGE}-kernel"
initrd_path="${KUBE_HOST_IMAGE}-initrd.img"
kernel_args="$(cat ${KUBE_HOST_IMAGE}-cmdline)"

linuxkit_bin="$(which linuxkit)"
exec ${linuxkit_bin} run -mem 4096 -cpus 2 -disk size=8 -state "${state}" -networking bridge,virbr0 -data-file "${state}/metadata.json" ${KUBE_HOST_IMAGE}

