# syntax=docker/dockerfile-upstream:1.4.0
FROM --platform=linux/amd64 debian:stable-slim

ARG BUNDLE_DIR
ARG BUNDLE_UID=65532
ARG BUNDLE_USER=nonroot
ARG BUNDLE_GID=0
RUN useradd ${BUNDLE_USER} -m -u ${BUNDLE_UID} -g ${BUNDLE_GID} -o

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get update && apt-get install -y ca-certificates

# exec mixin has no buildtime dependencies

ENV HELM_EXPERIMENTAL_OCI=1
RUN apt-get update && apt-get install -y curl
RUN curl https://get.helm.sh/helm-v3.8.2-linux-amd64.tar.gz --output helm3.tar.gz
RUN tar -xvf helm3.tar.gz && rm helm3.tar.gz
RUN mv linux-amd64/helm /usr/local/bin/helm3
RUN curl -o kubectl https://storage.googleapis.com/kubernetes-release/release/v1.22.1/bin/linux/amd64/kubectl &&\
    mv kubectl /usr/local/bin && chmod a+x /usr/local/bin/kubectl


COPY --link . ${BUNDLE_DIR}
RUN rm ${BUNDLE_DIR}/porter.yaml
RUN rm -fr ${BUNDLE_DIR}/.cnab
COPY --link .cnab /cnab
RUN chgrp -R ${BUNDLE_GID} /cnab && chmod -R g=u /cnab
USER ${BUNDLE_UID}
WORKDIR ${BUNDLE_DIR}
CMD ["/cnab/app/run"]