# kuberneteskit

[![CircleCI](https://circleci.com/gh/kuberneteskit/kuberneteskit.svg?style=svg)](https://circleci.com/gh/kuberneteskit/kuberneteskit)

This project takes inspiration from LinuxKit and LinuxKit Kubernetes, but instead of running the kubelet in a container, it adds the kubelet (and some minimal dependencies) to the base init

This is currently a very rough work in progress

## Building

```sh
for pkg in cni-plugins critools kubelet; do
  linuxkit pkg build -org kuberneteskit -disable-content-trust pkg/$pkg
done

# Ensure that the image yml definitions are up to date for package changes
make update-hashes

make base
```

## Running

Running the below commands assumes that you are running on a Linux host with an existing virbr0 bridge device that is configured for use with `qemu-bridge-helper`

```sh
./boot.sh
```

Currently this brings up a single control plane host.

## Adding a node

```sh
KUBE_HOST_TYPE=node ./boot.sh
```

This will bring up an unconfigured system running the kubelet. You will need to retrieve the join command from the kubeadm log from the master.

```sh
grep 'kubeadm join' /var/log/kubeadm.out
```

When running the join command on the node you will need to also append `--ignore-preflight-errors=all`

## Debugging

### Connecting to host

The base image runs an ssh container that allows you to access a namespaced shell

To connect to default controlplane instance:

```sh
host_mac=$(cat kube-controlplane-state/mac-addr)
host_ip=$(arp -n | grep ${host_mac} | awk '{print $1}')
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${host_ip}
```

To connect to the default node instance:

```sh
host_mac=$(cat kube-node-state/mac-addr)
host_ip=$(arp -n | grep ${host_mac} | awk '{print $1}')
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${host_ip}
```

Verify that kubeadm has finished by checking if /etc/kubernetes/.kubeadm.init.finished exists.

Check the kubeadm output

```sh
less /var/log/kubeadm.out
```

Check the kubelet logs

```sh
less /var/log/kubelet.out
```

### Entering the root namespace

Use nsenter to run a shell in the same namespaces as containerd

```sh
nsenter -t `pgrep containerd | head -n 1` -a ash -l
```
