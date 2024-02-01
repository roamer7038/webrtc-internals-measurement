FROM alpine:latest

RUN apk add --no-cache curl jq bash

COPY init-influxdb.sh /init-influxdb.sh
RUN chmod +x /init-influxdb.sh

ENTRYPOINT ["bash" , "/init-influxdb.sh"]