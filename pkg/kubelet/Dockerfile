FROM linuxkit/alpine:f3cd219615428b2bd943411723eb28875275fae7 AS build

ENV kubernetes_version v1.10.2

RUN apk add -U --no-cache \
  bash \
  coreutils \
  curl \
  findutils \
  git \
  go \
  grep \
  libc-dev \
  linux-headers \
  make \
  rsync \
  && true

ENV GOPATH=/go PATH=$PATH:/go/bin

### Kubernetes (incl Kubelet)

ENV KUBERNETES_URL https://github.com/kubernetes/kubernetes.git
#ENV KUBERNETES_BRANCH pull/NNN/head
ENV KUBERNETES_COMMIT ${kubernetes_version}
RUN mkdir -p $GOPATH/src/github.com/kubernetes && \
    cd $GOPATH/src/github.com/kubernetes && \
    git clone $KUBERNETES_URL kubernetes
WORKDIR $GOPATH/src/github.com/kubernetes/kubernetes
RUN set -e; \
    if [ -n "$KUBERNETES_BRANCH" ] ; then \
        git fetch origin "$KUBERNETES_BRANCH"; \
    fi; \
    git checkout -q $KUBERNETES_COMMIT

RUN make WHAT="cmd/kubelet cmd/kubectl cmd/kubeadm"

## Construct final image
RUN mkdir -p /out/usr/bin /out/etc/init.d /out/etc/kubernetes
RUN echo "${kubernetes_version}" > /out/etc/kubernetes-release
RUN cp $GOPATH/src/github.com/kubernetes/kubernetes/_output/bin/kubelet /out/usr/bin/kubelet
RUN cp $GOPATH/src/github.com/kubernetes/kubernetes/_output/bin/kubeadm /out/usr/bin/kubeadm
RUN cp $GOPATH/src/github.com/kubernetes/kubernetes/_output/bin/kubectl /out/usr/bin/kubectl
ADD kubelet.init /out/etc/init.d/30-kubelet
ADD runkubelet.sh /out/usr/bin/runkubelet.sh
ADD runkubeadm.sh /out/usr/bin/runkubeadm.sh

FROM scratch
WORKDIR /
ENTRYPOINT []
CMD []
COPY --from=build /out/ /
