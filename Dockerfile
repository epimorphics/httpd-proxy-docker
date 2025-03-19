FROM bitnami/apache:2.4.58-debian-11-r0 as base
ARG image_name
ARG git_branch
ARG git_commit_hash
ARG github_run_number
ARG version

FROM base as builder

USER 0
RUN install_packages build-essential automake libtool curl

## Build mod_maxminddb with supporting library
RUN mkdir /build; cd /build \
    && curl -sL https://github.com/maxmind/libmaxminddb/releases/download/1.12.2/libmaxminddb-1.12.2.tar.gz > libmaxminddb-1.12.2.tar.gz \
    && ls -l \
    && tar zxf libmaxminddb-1.12.2.tar.gz  \
    && cd libmaxminddb-1.12.2 \
    && ./configure \
    && make \
    && make install \
    && ldconfig
RUN cd /build \
    && curl -sL https://github.com/maxmind/mod_maxminddb/releases/download/1.2.0/mod_maxminddb-1.2.0.tar.gz >  mod_maxminddb-1.2.0.tar.gz \
    && tar zxf mod_maxminddb-1.2.0.tar.gz \
    && cd mod_maxminddb-1.2.0 \
    && ./configure \
    && make install

FROM base
ARG image_name
ARG git_branch
ARG git_commit_hash
ARG github_run_number
ARG version

USER 0
RUN install_packages libjansson4 libhiredis0.14 libapache2-mod-qos libapache2-mod-auth-openidc apache2-bin
RUN sed -i -e 's/mpm_prefork/mpm_worker/g' /opt/bitnami/apache/conf/httpd.conf

## Install mod_maxmind
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /opt/bitnami/apache/modules/mod_maxminddb.so /opt/bitnami/apache/modules/mod_maxminddb.so
COPY --from=builder /opt/bitnami/apache/modules/mod_maxminddb.so /usr/lib/apache2/modules/mod_maxminddb.so
RUN echo /usr/local/lib  >> /etc/ld.so.conf.d/local.conf && ldconfig

## Cache set up
COPY cache-clear /usr/local/bin/cache-clear
RUN  mkdir -p /var/cache/apache2/mod_cache_disk && chown 1001 /var/cache/apache2/mod_cache_disk
USER 1001

## Load extra modules
COPY mods-enabled.conf /opt/bitnami/apache/conf/vhosts/mods-enabled.conf

LABEL com.epimorphics.name=$image_name \
      com.epimorphics.branch=$git_branch \
      com.epimorphics.build=$github_run_number \
      com.epimorphics.commit=$git_commit_hash \
      com.epimorphics.version=$version
