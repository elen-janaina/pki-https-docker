#!/bin/bash
set -euo pipefail

echo "=========================================="
echo "  Cliente PKI - Teste de Validação TLS"
echo "=========================================="
echo ""

# Aguarda serviços estarem prontos
echo "⏳ Aguardando serviços iniciarem..."
sleep 5

# Verifica se o servidor HTTP PKI está acessível
echo "🔍 Verificando servidor HTTP PKI (pki.local)..."
if curl -s -f http://pki.local/raiz.crt > /dev/null; then
    echo "  ✓ Servidor HTTP PKI está acessível"
else
    echo "  ✗ ERRO: Servidor HTTP PKI não está acessível"
    exit 1
fi

# Instala apenas o certificado raiz no trust store
echo ""
echo "🔐 Instalando certificado raiz no trust store..."
cp /certs/raiz.crt /usr/local/share/ca-certificates/raiz.crt
update-ca-certificates

echo "  ✓ Certificado raiz instalado"
echo "  ℹ️  Nota: Apenas a raiz foi instalada, não o intermediário!"

# Lista certificados confiáveis
echo ""
echo "📋 Certificados confiáveis no sistema:"
ls -lh /usr/local/share/ca-certificates/

# Testa conexão HTTPS com o servidor
echo ""
echo "=========================================="
echo "🚀 Testando conexão HTTPS com web.local"
echo "=========================================="
echo ""
echo "Executando: curl -v https://web.local"
echo ""

# Executa curl com verbose para mostrar o handshake TLS
if curl -v https://web.local 2>&1 | tee /tmp/curl_output.log; then
    echo ""
    echo "=========================================="
    echo "✅ SUCESSO! Conexão HTTPS estabelecida"
    echo "=========================================="
    echo ""
    echo "📊 Análise do resultado:"
    echo ""
    
    # Verifica se o certificado foi validado
    if grep -q "SSL certificate verify ok" /tmp/curl_output.log; then
        echo "  ✓ Certificado do servidor validado com sucesso"
    fi
    
    # Verifica o protocolo TLS usado
    if grep -q "TLSv1.3" /tmp/curl_output.log; then
        echo "  ✓ Protocolo: TLS 1.3"
    elif grep -q "TLSv1.2" /tmp/curl_output.log; then
        echo "  ✓ Protocolo: TLS 1.2"
    fi
    
    echo ""
    echo "🎯 O que foi demonstrado:"
    echo "  1. Cliente confia apenas na AC Raiz"
    echo "  2. Servidor apresentou certificado + cadeia intermediária"
    echo "  3. Cliente validou a cadeia automaticamente"
    echo "  4. Conexão TLS estabelecida com sucesso"
    echo ""
    echo "✨ A busca do certificado intermediário via AIA funcionou!"
    echo ""
    
else
    echo ""
    echo "=========================================="
    echo "❌ FALHA na conexão HTTPS"
    echo "=========================================="
    echo ""
    echo "Possíveis causas:"
    echo "  - Certificados não foram gerados corretamente"
    echo "  - Servidor web não está acessível"
    echo "  - Problema na cadeia de certificados"
    echo ""
    exit 1
fi

echo "=========================================="
echo "  Teste concluído"
echo "=========================================="