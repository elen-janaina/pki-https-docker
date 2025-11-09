#!/bin/bash
set -euo pipefail

# Define diretórios
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PKI_DIR="$PROJECT_ROOT/pki"
ROOT_DIR="$PKI_DIR/raiz"
INT_DIR="$PKI_DIR/intermediaria"

echo "🔐 Gerando AC Intermediária..."

# Garante diretórios
mkdir -p "$INT_DIR/private" "$INT_DIR/certs" "$INT_DIR/crl" "$INT_DIR/newcerts"
mkdir -p "$PKI_DIR/published/crl"

# Inicializa arquivos de controle
touch "$INT_DIR/index.txt"
echo 1000 > "$INT_DIR/serial"
echo 1000 > "$INT_DIR/crlnumber"

# 1. Gera chave privada da intermediária
openssl genpkey -algorithm RSA \
  -out "$INT_DIR/private/intermediaria.key.pem" \
  -pkeyopt rsa_keygen_bits:4096

chmod 400 "$INT_DIR/private/intermediaria.key.pem"

# 2. Gera CSR da intermediária (Subject DEVE ser igual ao da raiz para policy_strict)
openssl req -config "$INT_DIR/openssl.cnf" \
  -new -sha256 \
  -key "$INT_DIR/private/intermediaria.key.pem" \
  -subj "/C=BR/ST=RS/L=Caraa/O=MeuProjeto/OU=PKI/CN=AC Intermediaria" \
  -out "$INT_DIR/intermediaria.csr.pem"

echo "  ✓ CSR da intermediária criado"

# 3. Assina CSR com a raiz (extensão v3_intermediate_ca)
openssl ca -config "$ROOT_DIR/openssl.cnf" \
  -extensions v3_intermediate_ca \
  -days 1825 -notext -md sha256 \
  -in "$INT_DIR/intermediaria.csr.pem" \
  -out "$INT_DIR/certs/intermediaria.crt.pem" \
  -batch

echo "  ✓ Certificado intermediário assinado pela raiz"

# 4. Gera CRL da intermediária
openssl ca -config "$INT_DIR/openssl.cnf" \
  -gencrl \
  -out "$INT_DIR/crl/intermediaria.crl.pem"

echo "  ✓ CRL da intermediária gerada"

# 5. Publica certificado e CRL
cp "$INT_DIR/certs/intermediaria.crt.pem" "$PKI_DIR/published/intermediaria.crt"
cp "$INT_DIR/crl/intermediaria.crl.pem" "$PKI_DIR/published/crl/intermediaria.crl"

echo "Artefatos publicados em: $PKI_DIR/published/"
echo "AC Intermediária criada com sucesso!"