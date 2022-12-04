# OpenSSL OCSP Responder

Configuration to run OpenSSL as an OCSP Responder as a Docker container.

https://www.openssl.org/docs/manmaster/man1/openssl-ocsp.html#OCSP-Server-Options

<br />

## Notes

- The CA Certificate, CA Index, Signing Certificate, and Signing Key files are **REQUIRED**.
- The CA Certificate **MAY** be used as the Signing Certificate if it contains the required extensions.
- When the CA Index attribute `unique_subject = no` is configured, the `index.attr` file **MUST** be provided with the `index` file.

<br />

## Environment Variables

| Environment Variable | Description | Default Value |
| -------------------- | ----------- | ------------- |
| `OPENSSL_RESPONDER_CA` | CA Certificate | /opt/openssl-responder/ca.crt |
| `OPENSSL_RESPONDER_INDEX` | OpenSSL CA Index | /opt/openssl-responder/index |
| `OPENSSL_RESPONDER_MULTI` | Number of child processes | 10 |
| `OPENSSL_RESPONDER_NDAYS` | Number of days used in the nextUpdate field | 364 days |
| `OPENSSL_RESPONDER_PORT` | OCSP Responder Listening Port | 8080 |
| `OPENSSL_RESPONDER_RKEY` | OCSP Responder Signing Key | /opt/openssl-responder/va.key |
| `OPENSSL_RESPONDER_RMD` | OCSP Response Signature Algorithm | sha384 |
| `OPENSSL_RESPONDER_RSIGNER` | OCSP Responder Signing Cert | /opt/openssl-responder/va.crt |
| `OPENSSL_RESPONDER_TIMEOUT` | OCSP Responder Timeout | 10 seconds |

<br />

## Volume Mount

`/opt/openssl-responder` can be mounted as a volume containing the CA Certificate (ca.crt), CA Index (index), Signing Certificate (va.crt), and Signing Key (va.key).

Files can also be mounted individually under different paths by updating their corresponding environment variables.

<br />

## Health Check

By default the first valid certificate serial in the CA Index is used to check for a valid OCSP response.

```
-serial "0x$(grep -m 1 -Po '^V\s+\d+Z\s+\K[0-9a-fA-F]+' ${OPENSSL_RESPONDER_INDEX})"
```

If all certificates in the CA Index are revoked, the health check can be reconfigured to use the first revoked certificate serial in the CA Index to check for a valid OCSP response.

```
-serial "0x$(grep -m 1 -Po '^R\s+\d+Z\s+\d+Z[,]*\w*\s+\K[0-9a-fA-F]+' ${OPENSSL_RESPONDER_INDEX})"
```