#!/bin/bash
set -euo pipefail

# Define diretórios
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PKI_DIR="$PROJECT_ROOT/pki"
INT_DIR="$PKI_DIR/intermediaria"
SERVER_DIR="$PKI_DIR/server"

echo "🔐 Gerando Certificado TLS do Servidor..."

# Garante diretórios
mkdir -p "$SERVER_DIR"

# 1. Gera chave privada do servidor
openssl genpkey -algorithm RSA \
  -out "$SERVER_DIR/server.key.pem" \
  -pkeyopt rsa_keygen_bits:2048

chmod 400 "$SERVER_DIR/server.key.pem"

# 2. Gera CSR do servidor
openssl req -new -sha256 \
  -key "$SERVER_DIR/server.key.pem" \
  -subj "/C=BR/ST=RJ/L=Rio/O=MeuProjeto/OU=Web/CN=web.local" \
  -out "$SERVER_DIR/server.csr.pem"

echo "CSR do servidor criado"

# 3. Assina CSR com a intermediária (extensão server_cert)
openssl ca -config "$INT_DIR/openssl.cnf" \
  -extensions server_cert \
  -days 825 -notext -md sha256 \
  -in "$SERVER_DIR/server.csr.pem" \
  -out "$SERVER_DIR/server.crt.pem" \
  -batch

echo "Certificado do servidor assinado pela intermediária"

# 4. Cria cadeia completa (servidor + intermediária)
cat "$SERVER_DIR/server.crt.pem" "$INT_DIR/certs/intermediaria.crt.pem" \
  > "$SERVER_DIR/server.chain.pem"

echo "Cadeia de certificados criada: server.chain.pem"

# 5. Verifica o certificado
echo ""
echo "Informações do certificado:"
openssl x509 -in "$SERVER_DIR/server.crt.pem" -noout -subject -issuer -dates -ext subjectAltName || true

echo ""
echo "Certificado TLS do Servidor criado com sucesso!"