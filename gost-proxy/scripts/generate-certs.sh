#!/bin/bash
# 生成自签名证书用于 HTTPS 代理测试
# 生产环境请使用正式证书

CERT_DIR="./certs"

mkdir -p $CERT_DIR

# 生成私钥
openssl genrsa -out $CERT_DIR/server.key 2048

# 生成证书签名请求 (CSR)
openssl req -new -key $CERT_DIR/server.key -out $CERT_DIR/server.csr -subj "/C=CN/ST=Beijing/L=Beijing/O=GostProxy/OU=IT/CN=localhost"

# 生成自签名证书 (有效期 365 天)
openssl x509 -req -days 365 -in $CERT_DIR/server.csr -signkey $CERT_DIR/server.key -out $CERT_DIR/server.crt

# 设置权限
chmod 600 $CERT_DIR/server.key
chmod 644 $CERT_DIR/server.crt

echo "✅ 证书生成完成:"
echo "   - 私钥: $CERT_DIR/server.key"
echo "   - 证书: $CERT_DIR/server.crt"
