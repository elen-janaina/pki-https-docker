FROM nginx:alpine

# Copia configuração customizada do nginx
COPY ./pki-http/default.conf /etc/nginx/conf.d/default.conf

# Cria diretório para CRLs
RUN mkdir -p /usr/share/nginx/html/crl

# Os certificados e CRLs serão montados via volume
# Veja docker-compose.yml: ./pki/published:/usr/share/nginx/html:ro

EXPOSE 80