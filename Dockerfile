FROM bitnami/apache:2.4-debian-10
ARG MOD_AUTH_OPENIDC_DEB 
ARG LIBCJOSE0

## Install openidc
USER 0
RUN install_packages libjansson4 libhiredis0.14 apache2-api-20120211 apache2-bin
COPY ${LIBCJOSE0} ${MOD_AUTH_OPENIDC_DEB} /var/opt/
RUN dpkg -i /var/opt/libcjose0_0.6.1.5-1~buster+1_amd64.deb /var/opt/libapache2-mod-auth-openidc_2.4.3-1~buster+1_amd64.deb

## Cache set up
COPY cache-clear /usr/local/bin/cache-clear
RUN  mkdir -p /var/cache/apache2/mod_cache_disk && chown 1001 /var/cache/apache2/mod_cache_disk
USER 1001

## Load extra modules
COPY mods-enabled.conf /opt/bitnami/apache/conf/vhosts/mods-enabled.conf
