# Use a clean tiny image to store artifacts in
FROM alpine:3.15.4

# Labels for http://label-schema.org/rc1/#build-time-labels
# And for https://github.com/opencontainers/image-spec/blob/master/annotations.md
# And for https://help.github.com/en/actions/building-actions/metadata-syntax-for-github-actions
ARG NAME="GitHub Action for creating Pull Requests"
ARG DESCRIPTION="GitHub Action that will create a pull request from the current branch"
ARG REPO_URL="https://github.com/devops-infra/action-pull-request"
ARG AUTHOR="Krzysztof Szyper / ChristophShyper / biotyk@mail.com"
ARG HOMEPAGE="https://christophshyper.github.io/"
ARG BUILD_DATE=2020-04-01T00:00:00Z
ARG VCS_REF=abcdef1
ARG VERSION=v0.0
LABEL \
  com.github.actions.name="${NAME}" \
  com.github.actions.author="${AUTHOR}" \
  com.github.actions.description="${DESCRIPTION}" \
  com.github.actions.color="purple" \
  com.github.actions.icon="upload-cloud" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.name="${NAME}" \
  org.label-schema.description="${DESCRIPTION}" \
  org.label-schema.usage="README.md" \
  org.label-schema.url="${HOMEPAGE}" \
  org.label-schema.vcs-url="${REPO_URL}" \
  org.label-schema.vcs-ref="${VCS_REF}" \
  org.label-schema.vendor="${AUTHOR}" \
  org.label-schema.version="${VERSION}" \
  org.label-schema.schema-version="1.0"	\
  org.opencontainers.image.created="${BUILD_DATE}" \
  org.opencontainers.image.authors="${AUTHOR}" \
  org.opencontainers.image.url="${HOMEPAGE}" \
  org.opencontainers.image.documentation="${REPO_URL}/blob/master/README.md" \
  org.opencontainers.image.source="${REPO_URL}" \
  org.opencontainers.image.version="${VERSION}" \
  org.opencontainers.image.revision="${VCS_REF}" \
  org.opencontainers.image.vendor="${AUTHOR}" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.title="${NAME}" \
  org.opencontainers.image.description="${DESCRIPTION}" \
  maintainer="${AUTHOR}" \
  repository="${REPO_URL}"

RUN adduser -D -g '' runner \
        && mkdir -p /etc/sudoers.d/ \
        && echo "runner ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/runner \
        && chmod 0440 /etc/sudoers.d/runner

RUN apk add --update sudo

RUN mkdir -p /github/workspace && chown -R runner:runner /github/workspace

USER runner

# Copy all needed files
COPY --chown=runner:runner entrypoint.sh /home/runner

# Install needed packages
RUN set -eux ;\
  chmod +x /home/runner/entrypoint.sh ;\
  sudo apk update --no-cache ;\
  sudo apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing hub~=2.14.2 ;\
  sudo apk add --no-cache \
    bash~=5.1.16 \
    git~=2.34.2 \
    jq~=1.6 ;\
  sudo rm -rf /var/cache/* ;\
  sudo rm -rf /root/.cache/*

# Finish up
CMD ["hub version"]
WORKDIR /github/workspace
ENTRYPOINT ["/home/runner/entrypoint.sh"]
