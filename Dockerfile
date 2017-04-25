FROM ubuntu:16.04

USER root

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y curl && \
    curl -s https://packagecloud.io/install/repositories/varnishcache/varnish5/script.deb.sh | bash &&\
    apt-get install -y varnish && \
    apt-get clean


EXPOSE 80

CMD ["/usr/sbin/varnishd","-F", "-f", "/etc/varnish/default.vcl"]
