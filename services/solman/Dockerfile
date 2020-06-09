FROM signavio-on-premise.jfrog.io/solman:latest

ENV CONFD_VERSION 0.16.0
RUN wget -q https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 -O /usr/local/bin/confd && \
    chmod +x /usr/local/bin/confd

# recreate application.yml file using confd inside of entrypoint.sh
RUN rm /usr/share/tomcat/app/config/application.yml

COPY config /etc/confd/

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/share/tomcat/bin/catalina.sh", "run"]
