FROM httpd:2.4.33-alpine
COPY httpd-extension.conf /tmp/
RUN cat /tmp/httpd-extension.conf >> /usr/local/apache2/conf/httpd.conf
COPY httpd-ssl-extension.conf /usr/local/apache2/conf/extra/httpd-ssl-extension.conf
RUN apk update && apk add curl
