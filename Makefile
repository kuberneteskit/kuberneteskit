KUBE_FORMATS ?= qcow2-bios
KUBE_FORMAT_ARGS ?= "-size 8G"
KUBE_FORMAT_ARGS := $(patsubst %,-format %,$(KUBE_FORMATS))

.PHONY: all base
all: base

base: yml/kubernetes-base.yml
	linuxkit $(LINUXKIT_ARGS) build $(LINUXKIT_BUILD_ARGS) -name kubernetes-base $(KUBE_FORMAT_ARGS) $^

.PHONY: update-hashes
update-hashes:
	set -e ; for tag in $$(linuxkit pkg show-tag pkg/kubelet) \
	           $$(linuxkit pkg show-tag pkg/critools) \
	           $$(linuxkit pkg show-tag pkg/cni-plugins) ; do \
	    image=$${tag%:*} ; \
	    sed -E -i -e "s,$$image:[[:xdigit:]]{40}(-dirty)?,$$tag,g" yml/*.yml ; \
	done

.PHONY: clean
clean:
	rm -f -r \
	  *.qcow2 linuxkit *-state
