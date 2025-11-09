FROM alpine:latest

# Instala curl e ca-certificates
RUN apk add --no-cache curl ca-certificates bash

# Copia script de teste
COPY ./client/test_and_verify.sh /usr/local/bin/test_and_verify.sh
RUN chmod +x /usr/local/bin/test_and_verify.sh

CMD ["/usr/local/bin/test_and_verify.sh"]