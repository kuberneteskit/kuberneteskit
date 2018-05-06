#!/bin/sh

if [ -n "$KUBELET_DISABLED" ]; then
    touch /run/config/kubelet/disabled
fi

if [[ ! -d /var/lib/kubernetes-config ]]; then
    mkdir -p /var/lib/kubernetes-config
fi

if ! mountpoint -q /etc/kubernetes; then
    mount --bind /var/lib/kubernetes-config /etc/kubernetes
fi

if ! mountpoint -q /opt/cni; then
    if [[ ! -d /var/lib/cni ]]; then
        mkdir -p /var/lib/cni
    fi
    if [[ ! -d /var/lib/cni-work ]]; then
        mkdir -p /var/lib/cni-work
    fi
    mount -t overlay -o lowerdir=/opt/cni,upperdir=/var/lib/cni,workdir=/var/lib/cni-work none /opt/cni
fi

if ! mountpoint -q /etc/cni/net.d; then
    if [[ ! -d /var/lib/cni-netd ]]; then
        mkdir -p var/lib/cni-netd
    fi
    if [[ ! -d /var/lib/cni-netd-work ]]; then
        mkdir -p /var/lib/cni-netd-work
    fi
    mount -t overlay -o lowerdir=/etc/cni/net.d,upperdir=/var/lib/cni-netd,workdir=/var/lib/cni-netd-work none /etc/cni/net.d
fi

if [[ -f /run/config/kubernetes/kubeadm-init ]]; then
    if [[ ! -f /etc/kubernetes/kubelet.conf ]]; then
        /usr/bin/runkubeadm.sh >> /var/log/kubeadm.out 2>&1 &
    fi
fi

# Keep attempting to run kubelet unless disabled file is present
while [[ ! -f /run/config/kubelet/disabled ]]; do
    kubelet --config=/run/config/kubernetes/kubelet-config.yaml \
      --kubeconfig=/etc/kubernetes/kubelet.conf \
      --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf \
      --allow-privileged=true \
      --client-ca-file=/etc/kubernetes/pki/ca.crt \
      --cadvisor-port=0 \
      --rotate-certificates=true \
      --cert-dir=/var/lib/kubelet/pki \
      --network-plugin=cni \
      --cni-conf-dir=/etc/cni/net.d \
      --cni-bin-dir=/opt/cni/bin \
      --container-runtime=remote \
      --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \
      >> /var/log/kubelet.out 2>&1
    sleep 15
done