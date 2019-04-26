#!/bin/bash
set -e
echo $SECRET > /etc/varnish/secret
dockerize -template /template.vcl:/etc/varnish/default.vcl
exec "$@"
