# build and push docker image to LR ECR repository
REPO?=293385631482.dkr.ecr.eu-west-1.amazonaws.com
IMAGE?=epimorphics/httpd-proxy-oauth
VERSION?=1.4

ARCHIVE=https://mod-auth-openidc.org/download

MOD_AUTH_OPENIDC=libapache2-mod-auth-openidc_2.4.3-1~buster+1_amd64.deb
LIBCJOSE0=libcjose0_0.6.1.5-1~buster+1_amd64.deb

DOWNLOADS= ${MOD_AUTH_OPENIDC} ${LIBCJOSE0}

.PHONY: image
all: publish

image: downloads
	docker build --build-arg MOD_AUTH_OPENIDC_DEB=${MOD_AUTH_OPENIDC} --build-arg LIBCJOSE0=${LIBCJOSE0} -t "$(IMAGE):latest" . 

.PHONY: tag
tag:
	docker tag "$(IMAGE):latest" "$(REPO)/$(IMAGE):$(VERSION)"

.PHONY: push
push:
	docker push "$(REPO)/$(IMAGE):$(VERSION)"
	
.PHONY: publish
publish: image tag push

downloads: ${DOWNLOADS}

${MOD_AUTH_OPENIDC}:
	@wget ${ARCHIVE}/$@

${LIBCJOSE0}:
	@wget ${ARCHIVE}/$@
	
clean:
	@rm -f ${DOWNLOADS}

