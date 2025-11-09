#!/bin/bash
set -euo pipefail

# Garante que o script execute a partir da raiz do projeto
cd "$(dirname "$0")/../.."

# Define diretórios
PROJECT_ROOT="$(pwd)"
PKI_DIR="$PROJECT_ROOT/pki"
ROOT_DIR="$PKI_DIR/raiz"

echo "Gerando Autoridade Certificadora Raiz..."

# 1. Cria estrutura de diretórios se não existir
mkdir -p "$ROOT_DIR"/{certs,crl,newcerts,private}
chmod 700 "$ROOT_DIR/private"

# 2. Inicializa arquivos de controle da CA
touch "$ROOT_DIR/index.txt"
echo 1000 > "$ROOT_DIR/serial"
echo 1000 > "$ROOT_DIR/crlnumber"

# 3. Gera chave privada da raiz
openssl genpkey -algorithm RSA \
  -out "$ROOT_DIR/private/raiz.key.pem" \
  -pkeyopt rsa_keygen_bits:4096

chmod 400 "$ROOT_DIR/private/raiz.key.pem"

# 4. Gera certificado autoassinado da raiz
openssl req -config "$ROOT_DIR/openssl.cnf" \
  -key "$ROOT_DIR/private/raiz.key.pem" \
  -new -x509 -days 3650 -sha256 \
  -subj "/C=BR/ST=RS/L=Caraa/O=MeuProjeto/OU=PKI/CN=AC Raiz" \
  -out "$ROOT_DIR/raiz.crt.pem"

chmod 444 "$ROOT_DIR/raiz.crt.pem"

echo "Certificado raiz criado em: $ROOT_DIR/raiz.crt.pem"

# 5. Gera CRL da raiz
openssl ca -config "$ROOT_DIR/openssl.cnf" \
  -gencrl \
  -out "$ROOT_DIR/crl/raiz.crl.pem"

echo "CRL da raiz gerada"

# 6. Publica certificado e CRL
mkdir -p "$PKI_DIR/published/crl"
cp "$ROOT_DIR/raiz.crt.pem" "$PKI_DIR/published/raiz.crt"
cp "$ROOT_DIR/crl/raiz.crl.pem" "$PKI_DIR/published/crl/raiz.crl"

echo ""
echo "Autoridade Certificadora Raiz criada com sucesso!"