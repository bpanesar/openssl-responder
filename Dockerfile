FROM ubuntu:22.04

ENV OPENSSL_RESPONDER_CA="/opt/openssl-responder/ca.crt"
ENV OPENSSL_RESPONDER_INDEX="/opt/openssl-responder/index"
ENV OPENSSL_RESPONDER_MULTI=10
ENV OPENSSL_RESPONDER_NDAYS=364
ENV OPENSSL_RESPONDER_PORT=8080
ENV OPENSSL_RESPONDER_RKEY="/opt/openssl-responder/va.key"
ENV OPENSSL_RESPONDER_RMD="sha384"
ENV OPENSSL_RESPONDER_RSIGNER="/opt/openssl-responder/va.crt"
ENV OPENSSL_RESPONDER_TIMEOUT=10

RUN apt-get update && apt-get upgrade -y && apt-get install openssl -y && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* /var/log/apt

RUN groupadd -r -g 9002 openssl-responder && useradd --no-log-init -r -d /opt/openssl-responder -g openssl-responder -u 9002 openssl-responder

USER openssl-responder

WORKDIR /opt/openssl-responder

EXPOSE "${OPENSSL_RESPONDER_PORT}"

HEALTHCHECK --start-period=10s --interval=30s --timeout=5s --retries=1 \
  CMD openssl ocsp \
      -issuer "${OPENSSL_RESPONDER_CA}" \
      -CAfile "${OPENSSL_RESPONDER_CA}" \
      -url "http://localhost:${OPENSSL_RESPONDER_PORT}" \
      -serial "0x$(grep -m 1 -Po '^V\s+\d+Z\s+\K[0-9a-fA-F]+' ${OPENSSL_RESPONDER_INDEX})" || exit 1
      #-serial "0x$(grep -m 1 -Po '^R\s+\d+Z\s+\d+Z[,]*\w*\s+\K[0-9a-fA-F]+' ${OPENSSL_RESPONDER_INDEX})" || exit 1

STOPSIGNAL SIGKILL

CMD openssl ocsp \
    -CA "${OPENSSL_RESPONDER_CA}" \
    -ignore_err \
    -index "${OPENSSL_RESPONDER_INDEX}" \
    -multi "${OPENSSL_RESPONDER_MULTI}" \
    -ndays "${OPENSSL_RESPONDER_NDAYS}" \
    -port "${OPENSSL_RESPONDER_PORT}" \
    -rkey "${OPENSSL_RESPONDER_RKEY}" \
    -rmd "${OPENSSL_RESPONDER_RMD}" \
    -rsigner "${OPENSSL_RESPONDER_RSIGNER}" \
    -timeout "${OPENSSL_RESPONDER_TIMEOUT}"