FROM linuxkit/alpine:f3cd219615428b2bd943411723eb28875275fae7 AS build

ENV cni_version v0.7.1

RUN apk add -U --no-cache curl && true
RUN mkdir -p /out/opt/cni/bin /out/etc/cni/net.d
RUN curl -L -o cni-plugins.tgz https://github.com/containernetworking/plugins/releases/download/${cni_version}/cni-plugins-amd64-v0.7.1.tgz
RUN tar -zxvf cni-plugins.tgz -C /out/opt/cni/bin/

FROM scratch
WORKDIR /
ENTRYPOINT []
CMD []
COPY --from=build /out /