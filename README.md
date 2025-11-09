# ICP-Demo (Trabalho de ICP) - 2025

## Objetivo
Montar uma infraestrutura de chaves públicas (AC Raiz, AC Intermediária, CRLs, AIA/CDP) em containers Docker e demonstrar validação TLS onde o cliente confia apenas na AC Raiz.

## Como executar (resumo)
Pré-requisitos: Docker + Docker Compose, openssl
💡 Obs: Os arquivos sensíveis (.key, .crt, .p12, etc.) não são enviados ao repositório por segurança. Então:
1. Gerar ICP:
   ```bash
   ./setup.sh
2. De acesso:

chmod 600 pki/server/server.key.pem

4. Subir containers:

docker compose up --build -d
 
5. Testes rápidos:

curl -v http://localhost:8080/raiz.crt 
curl -v http://localhost:8080/intermediaria.crt 
curl -v http://localhost:8080/intermediaria.crl 
curl -v --cacert pki/published/raiz.crt https://localhost:8443

4. Para parar:

docker compose down