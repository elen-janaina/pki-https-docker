ICP-Demo (Trabalho de ICP) - 2025

Montar uma infraestrutura de chaves públicas (AC Raiz, AC Intermediária, CRLs, AIA/CDP) em containers Docker e demonstrar validação TLS onde o cliente confia apenas na AC Raiz.

Como executar

Pré-requisitos

Docker + Docker Compose instalados
Sistema operacional: Linux ou WSL2 (recomendado)

Executar o projeto (um único comando!)
docker compose up --build

Pronto! O sistema irá:

Gerar automaticamente toda a infraestrutura PKI (AC Raiz, AC Intermediária, certificados)
Subir o servidor HTTP que publica os certificados
Subir o servidor HTTPS com TLS
Executar o cliente que valida a conexão

Testes manuais (opcional)
Se quiser testar manualmente após os containers estarem rodando:

# Verificar certificados publicados
curl -v http://localhost:8080/raiz.crt
curl -v http://localhost:8080/intermediaria.crt
curl -v http://localhost:8080/crl/intermediaria.crl

# Testar conexão HTTPS (do host)
curl -v --cacert pki/published/raiz.crt https://localhost:8443

# Parar os containers
docker compose down