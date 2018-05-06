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

```sh
./boot.sh
```

Currently this brings up the base system that has the kubelet, kubectl, and kubeadm binaries installed, but is not configured and the kubelet service is not running.

## Debugging

### Connecting to host

The base image runs an ssh container that allows you to access a namespaced shell

```sh
ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost
```

### Entering the root namespace

Use nsenter to run a shell in the same namespaces as containerd

```sh
nsenter -t `pgrep containerd | head -n 1` -a ash -l
```
