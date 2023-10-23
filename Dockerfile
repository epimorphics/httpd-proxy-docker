FROM bitnami/apache:2.4.58-debian-11-r0

ARG image_name
ARG build_date
ARG git_branch
ARG git_commit_hash
ARG github_run_number
ARG version

USER 0
RUN install_packages libjansson4 libhiredis0.14 libapache2-mod-qos libapache2-mod-auth-openidc apache2-bin
RUN sed -i -e 's/mpm_prefork/mpm_worker/g' /opt/bitnami/apache/conf/httpd.conf

## Cache set up
COPY cache-clear /usr/local/bin/cache-clear
RUN  mkdir -p /var/cache/apache2/mod_cache_disk && chown 1001 /var/cache/apache2/mod_cache_disk
USER 1001

## Load extra modules
COPY mods-enabled.conf /opt/bitnami/apache/conf/vhosts/mods-enabled.conf

LABEL com.epimorphics.name=$image_name \
      com.epimorphics.branch=$git_branch \
      com.epimorphics.build=$github_run_number \
      com.epimorphics.created=$build_date \
      com.epimorphics.commit=$git_commit_hash \
      com.epimorphics.version=$version
