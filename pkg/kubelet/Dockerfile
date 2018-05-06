FROM linuxkit/alpine:f3cd219615428b2bd943411723eb28875275fae7 AS build

ENV kubernetes_version v1.10.2

RUN apk add -U --no-cache curl && true


RUN mkdir -p /out/usr/bin /out/etc/init.d /out/etc/kubernetes
RUN curl -L -O https://dl.k8s.io/${kubernetes_version}/kubernetes-node-linux-amd64.tar.gz
RUN tar -zxvf kubernetes-node-linux-amd64.tar.gz
RUN cp kubernetes/node/bin/kubelet /out/usr/bin/kubelet
RUN cp kubernetes/node/bin/kubeadm /out/usr/bin/kubeadm
RUN cp kubernetes/node/bin/kubectl /out/usr/bin/kubectl
ADD kubelet.init /out/etc/init.d/30-kubelet
ADD runkubelet.sh /usr/bin/runkubelet.sh
ADD runkubeadm.sh /usr/bin/runkubeadm.sh

FROM scratch
WORKDIR /
ENTRYPOINT []
CMD []
COPY --from=build /out/ /
