FROM varnish:7.6.0

USER root

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y curl && \
    apt-get clean

RUN curl -s https://raw.githubusercontent.com/camptocamp/docker-odoo-project/master/install/dockerize.sh | bash

COPY config/template.vcl /template.vcl
COPY config/entrypoint.sh /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/sbin/varnishd","-F", "-f", "/etc/varnish/default.vcl"]
