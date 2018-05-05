FROM linuxkit/alpine:f3cd219615428b2bd943411723eb28875275fae7 AS build

ENV critools_version   v1.0.0-beta.1

RUN apk add -U --no-cache \
  bash \
  curl \
  findutils \
  git \
  go \
  libc-dev \
  make \
  && true

ENV GOPATH=/go PATH=$PATH:/go/bin

### critools

ENV CRITOOLS_URL https://github.com/kubernetes-incubator/cri-tools
#ENV CRITOOLS_BRANCH pull/NNN/head
ENV CRITOOLS_COMMIT ${critools_version}
RUN mkdir -p $GOPATH/github.com/kubernetes-incubator/ && \
    cd $GOPATH/github.com/kubernetes-incubator/ && \
    git clone $CRITOOLS_URL cri-tools
WORKDIR $GOPATH/github.com/kubernetes-incubator/cri-tools
RUN set -e;  \
    if [ -n "$CRITOOLS_BRANCH" ] ; then \
        git fetch origin "CRITOOLS_BRANCH"; \
    fi; \
    git checkout -q $CRITOOLS_COMMIT
RUN make binaries

RUN mkdir -p /out/usr/bin
RUN cp $GOPATH/bin/crictl /out/usr/bin/crictl
RUN cp $GOPATH/bin/critest /out/usr/bin/critest

FROM scratch
WORKDIR /
ENTRYPOINT []
CMD []
COPY --from=build /out/usr/bin/crictl /out/usr/bin/critest /usr/bin/
