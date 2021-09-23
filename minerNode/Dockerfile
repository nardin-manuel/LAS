FROM ethereum/client-go:stable

RUN  apk add curl jq
COPY init.sh /opt/init.sh
ENTRYPOINT ["/opt/init.sh"]