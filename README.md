# kuberneteskit

[![CircleCI](https://circleci.com/gh/kuberneteskit/kuberneteskit.svg?style=svg)](https://circleci.com/gh/kuberneteskit/kuberneteskit)

This project takes inspiration from LinuxKit and LinuxKit Kubernetes, but instead of running the kubelet in a container, it adds the kubelet (and some minimal dependencies) to the base init

This is currently a very rough work in progress

## Building

```sh
for pkg in cni-plugins critools kubelet; do
  linuxkit pkg build -org kuberneteskit -disable-content-trust pkg/$pkg
done

linuxkit build -name kubernetes-base -format qcow2-bios -size 8G yml/kubernetes-base.yml
```

## Running

```sh
linuxkit run -publish 2222:22 -mem 2048 -cpus 2 -disk size=8 kubernetes-base.qcow2
```

Currently this brings up the base system that has the kubelet, kubectl, and kubeadm binaries installed, but is not configured and the kubelet service is not running.

## Debugging

### Connecting to host

The base image runs an ssh container that allows you to access a namespaced shell

```sh
ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost
```

### Entering the root namespace

First, get the pid of a process running in the root namespace, such as containerd

```sh
pgrep containerd
```

Use nsenter to run a shell in the same namespaces as containerd

```sh
nsenter -t <pid of containerd> -a ash -l
```
