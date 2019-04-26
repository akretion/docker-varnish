FROM ubuntu:bionic-20181018

USER root

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y curl && \
    curl -s https://packagecloud.io/install/repositories/varnishcache/varnish60lts/script.deb.sh | bash &&\
    apt-get install -y varnish varnish-dev && \
    apt-get clean

RUN mkdir /tmp/varnish && \
    cd /tmp/varnish && \
    curl https://download.varnish-software.com/varnish-modules/varnish-modules-0.15.0.tar.gz -o modules.tar.gz && \
    tar zxvf modules.tar.gz && \
    cd varnish-modules-0.15.0 && \
    ./configure && make && make install && \
    rm -rf /tmp/varnish

RUN curl -s https://raw.githubusercontent.com/camptocamp/docker-odoo-project/master/install/dockerize.sh | bash

COPY config/template.vcl /template.vcl
COPY config/entrypoint.sh /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/sbin/varnishd","-F", "-f", "/etc/varnish/default.vcl"]
