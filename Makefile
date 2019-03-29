MACHINE=$(shell uname -m)
ACCOUNT=nandyio
IMAGE=speech-node-daemon
VERSION?=0.1
VOLUMES=-v ${PWD}/lib/:/opt/nandy-io/lib/ \
		-v ${PWD}/test/:/opt/nandy-io/test/ \
		-v ${PWD}/bin/:/opt/nandy-io/bin/

.PHONY: build shell test run push create update delete

ifeq ($(MACHINE),armv7l)
DEVICE=--device=/dev/vchiq
endif

build:
	docker build . -f $(MACHINE).Dockerfile -t $(ACCOUNT)/$(IMAGE):$(VERSION)

shell:
	docker run $(DEVICE)-it $(VOLUMES) $(ACCOUNT)/$(IMAGE):$(VERSION) sh

test:
	docker run $(DEVICE) -it $(VOLUMES) $(ACCOUNT)/$(IMAGE):$(VERSION) sh -c "coverage run -m unittest discover -v test && coverage report -m --include lib/service.py"

run:
	docker run $(DEVICE) -it $(VOLUMES) --rm -h $(IMAGE) $(ACCOUNT)/$(IMAGE):$(VERSION)

push:
ifeq ($(MACHINE),armv7l)
	docker push $(ACCOUNT)/$(IMAGE):$(VERSION)
else
	echo "Only push armv7l"
endif
	
create:
	kubectl create -f kuberetes/daemon.yaml

delete:
	kubectl delete -f kuberetes/daemon.yaml

update: delete create