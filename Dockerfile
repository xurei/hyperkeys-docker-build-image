FROM node:6.7.0

USER root

RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get install -y --no-install-recommends tree nsis wine wine32 xauth g++ g++-mingw-w64-i686 sudo
RUN apt-get clean

# first create user and group for all the X Window stuff
# required to do this first so we have consistent uid/gid between server and client container
RUN addgroup --system xusers \
  && adduser \
			--home /home/xclient \
			--disabled-password \
			--shell /bin/bash \
			--gecos "user for running an xclient application" \
			--ingroup xusers \
			--quiet \
			xclient

RUN usermod -a -G root xclient

# Before switching user, root needs to ensure that entrypoint can be executed.
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN chown root:root /home/xclient

# During startup we need to prepare connection to X11-Server container
ENTRYPOINT ["/entrypoint.sh"]

# Wine really doesn't like to be run as root, so let's use a non-root user
ENV HOME /home/xclient
ENV WINEPREFIX /home/xclient/.wine
ENV WINEARCH win32
RUN wine wineboot --init

# Use xclient's home dir as working dir
WORKDIR /home/xclient