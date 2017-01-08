FROM node:4.6.0

USER root

RUN apt-get update
RUN apt-get -y install tree nsis wine
RUN apt-get clean
