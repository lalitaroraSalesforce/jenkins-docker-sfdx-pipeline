FROM node:alpine

RUN apk add --update --no-cache git openssh ca-certificates openssl jq gettext xmlstarlet openjdk8 curl zip unzip bash

ARG USER_ID=1000
ARG GROUP_ID=1000
RUN addgroup -g $GROUP_ID jenkins-ci && \
    adduser -u $USER_ID -s /bin/sh -G jenkins-ci jenkins-ci -h /home/jenkins-ci -D

RUN npm install sfdx-cli --global
RUN sfdx --version
RUN sfdx plugins --core

RUN rm -rf /root/.npm
RUN rm -rf /root/.sfdx
RUN rm -rf /root/.local/share/sfdx
RUN rm -rf /root/.config/sfdx
RUN rm -rf /root/.cache/sfdx