FROM nginx:alpine

# Instala wget para healthcheck
RUN apk add --no-cache wget

# Copia configuração do nginx
COPY ./web/nginx.conf /etc/nginx/nginx.conf

# Copia certificados do servidor
COPY ./pki/server/server-fullchain.crt.pem /etc/ssl/private/server-fullchain.crt.pem
COPY ./pki/server/server.key.pem /etc/ssl/private/server.key.pem
RUN chmod 600 /etc/ssl/private/server.key.pem

# Ajusta permissões
RUN chmod 600 /etc/ssl/private/server.key.pem

# Copia página HTML
COPY ./web/index.html /usr/share/nginx/html/index.html

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]