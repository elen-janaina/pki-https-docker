#!/bin/bash
set -euo pipefail

echo "=========================================="
echo "  PKI Setup - Infraestrutura Completa"
echo "=========================================="

# Define diretório base
PROJECT_ROOT="/pki"
PKI_DIR="$PROJECT_ROOT"

# Verifica se já foi executado
if [ -f "$PKI_DIR/published/raiz.crt" ] && [ -f "$PKI_DIR/server/server.key.pem" ]; then
    echo "✅ PKI já foi gerada anteriormente. Pulando..."
    exit 0
fi

# 1. Limpar artefatos anteriores
echo ""
echo "🧹 Limpando artefatos anteriores..."
rm -rf "$PKI_DIR/raiz/private" "$PKI_DIR/raiz/certs" "$PKI_DIR/raiz/crl" "$PKI_DIR/raiz/newcerts"
rm -rf "$PKI_DIR/intermediaria/private" "$PKI_DIR/intermediaria/certs" "$PKI_DIR/intermediaria/crl" "$PKI_DIR/intermediaria/newcerts"
rm -rf "$PKI_DIR/server"
rm -rf "$PKI_DIR/published"
rm -f "$PKI_DIR/raiz/index.txt"* "$PKI_DIR/raiz/serial"* "$PKI_DIR/raiz/crlnumber"*
rm -f "$PKI_DIR/intermediaria/index.txt"* "$PKI_DIR/intermediaria/serial"* "$PKI_DIR/intermediaria/crlnumber"*

# 2. Criar estrutura de diretórios
echo "📁 Criando estrutura de diretórios..."
mkdir -p "$PKI_DIR/raiz/"{private,certs,crl,newcerts}
mkdir -p "$PKI_DIR/intermediaria/"{private,certs,crl,newcerts}
mkdir -p "$PKI_DIR/server"
mkdir -p "$PKI_DIR/published/crl"

# 3. Ajustar permissões
chmod 700 "$PKI_DIR/raiz/private"
chmod 700 "$PKI_DIR/intermediaria/private"

# 4. Inicializar arquivos de estado
echo "📝 Inicializando arquivos de estado..."
touch "$PKI_DIR/raiz/index.txt"
echo "1000" > "$PKI_DIR/raiz/serial"
echo "1000" > "$PKI_DIR/raiz/crlnumber"

touch "$PKI_DIR/intermediaria/index.txt"
echo "1000" > "$PKI_DIR/intermediaria/serial"
echo "1000" > "$PKI_DIR/intermediaria/crlnumber"

# 5. Gerar PKI
echo ""
echo "🔐 Gerando AC Raiz..."
bash "$PKI_DIR/scripts/gen_root.sh"

echo ""
echo "🔐 Gerando AC Intermediária..."
bash "$PKI_DIR/scripts/gen_intermediate.sh"

echo ""
echo "🔐 Gerando Certificado TLS do Servidor..."
bash "$PKI_DIR/scripts/gen_server.sh"

# 6. Ajustar permissões finais
chmod 600 "$PKI_DIR/server/server.key.pem"

echo ""
echo "=========================================="
echo "✅ PKI gerada com sucesso!"
echo "=========================================="
echo ""
echo "Artefatos publicados em: $PKI_DIR/published/"
echo "=========================================="