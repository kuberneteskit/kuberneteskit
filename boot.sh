#!/bin/sh

set -e


KUBEADM_CONFIG=$(cat <<EOF
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
)
echo -e "Using kubeadm config:\n${KUBEADM_CONFIG}"

KUBELET_CONFIG=$(cat <<EOF
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
staticPodPath: /etc/kubernetes/manifests
clusterDomain: cluster.local
clusterDNS:
  - 10.96.0.10
makeIPTablesUtilChains: false
EOF
)
echo -e "Using kubelet config:\n${KUBELET_CONFIG}"

KUBEADM_CONFIG=$(echo "${KUBEADM_CONFIG}" | awk '{printf "%s\\n", $0}')
KUBELET_CONFIG=$(echo "${KUBELET_CONFIG}" | awk '{printf "%s\\n", $0}')

METADATA=$(cat <<EOF
{
    "kubernetes": {
        "entries": {
            "kubeadm-init": {
                "content": "${KUBEADM_CONFIG}"
            },
            "kubelet-config.yaml": {
                "content": "${KUBELET_CONFIG}"
            }
        }
    }
}
EOF
)
echo "Generated metadata:"
echo "${METADATA}"

echo "${METADATA}" > kubernetes-base.meta
linuxkit run -publish 2222:22 -mem 2048 -cpus 2 -disk size=8 -data-file kubernetes-base.meta kubernetes-base.qcow2
