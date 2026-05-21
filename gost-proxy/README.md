# Gost HTTP/HTTPS 代理服务器

基于 Docker 的 Gost 代理服务器，使用官方 Gost UI 进行可视化管理。

---

## ✨ 功能特性

- 🔐 **用户认证** - 支持多用户管理，独立密码
- 🌐 **HTTP/HTTPS 代理** - 支持 HTTP CONNECT 隧道
- 📊 **官方 Web UI** - 使用 [Gost UI](https://github.com/go-gost/gost-ui) 可视化管理
- 🐳 **Docker 部署** - 一键启动，方便迁移
- 🔧 **动态配置** - 通过 Web UI 动态管理用户和服务
- 🔒 **安全配置** - 支持 TLS 加密

---

## 📁 项目结构

```
gost-proxy/
├── docker-compose.yml      # Docker 编排配置
├── gost.yaml              # Gost 代理配置
├── DEPLOYMENT.md          # 详细部署文档 (Amazon Linux 2023)
├── README.md              # 本文件
├── scripts/
│   └── generate-certs.sh  # SSL 证书生成脚本
├── certs/                 # SSL 证书目录
│   ├── server.crt
│   └── server.key
└── data/                  # 数据存储目录
```

---

## 🚀 快速开始

### 1. 前置要求

- Docker 20.10+
- Docker Compose V2

### 2. 克隆项目

```bash
git clone https://github.com/ywyang/kiro-demos.git
cd kiro-demos/gost-proxy
```

### 3. 生成证书（用于 HTTPS 代理）

```bash
chmod +x scripts/generate-certs.sh
./scripts/generate-certs.sh
```

### 4. 启动服务

```bash
docker compose up -d
```

### 5. 访问服务

| 服务 | 地址 | 说明 |
|------|------|------|
| **Gost UI** | http://localhost:3000 | Web 管理界面 |
| HTTP 代理 | localhost:8080 | HTTP/HTTPS 代理 |
| HTTPS 代理 | localhost:8443 | TLS 加密代理 |

---

## 📖 使用 Web UI 管理

### 连接到 Gost

1. 打开 http://localhost:3000
2. 填写连接信息：
   - **API 地址**: `http://服务器IP:18080`
   - **用户名/密码**: 留空（未配置认证）
3. 点击 **连接** 按钮

### 管理用户

连接成功后，可以在 Web UI 中：
- 添加/删除/修改用户
- 管理代理服务
- 查看运行状态
- 配置链式代理

> 💡 **提示**: 也可以使用官方在线 UI: https://ui.gost.run

---

## 🔧 配置代理客户端

### 浏览器配置

在浏览器代理设置中填写：
- 地址: `服务器IP`
- 端口: `8080`
- 用户名/密码: 在 Web UI 创建的用户

### 命令行配置

```bash
export http_proxy=http://user1:pass123@服务器IP:8080
export https_proxy=http://user1:pass123@服务器IP:8080

# 测试
curl http://httpbin.org/ip
```

### Python 代码

```python
import requests

proxies = {
    'http': 'http://user1:pass123@服务器IP:8080',
    'https': 'http://user1:pass123@服务器IP:8080'
}
response = requests.get('https://httpbin.org/ip', proxies=proxies)
print(response.json())
```

### curl 使用

```bash
# 通过代理访问
curl -x http://user1:pass123@服务器IP:8080 https://httpbin.org/ip
```

---

## 🛠️ 管理命令

```bash
# 查看状态
docker compose ps

# 查看日志
docker compose logs -f gost

# 重启服务
docker compose restart

# 停止服务
docker compose down

# 更新镜像
docker compose pull && docker compose up -d
```

---

## 📝 默认用户

配置文件 `gost.yaml` 中预置了测试用户：

| 用户名 | 密码 |
|--------|------|
| user1 | pass123 |
| user2 | pass456 |

> ⚠️ **生产环境建议**: 通过 Web UI 修改或删除默认用户

---

## 📖 详细部署文档

完整部署指南（Amazon Linux 2023）请查看: [DEPLOYMENT.md](./DEPLOYMENT.md)

---

## 🔒 安全建议

1. **修改默认用户密码**
2. **限制 API 端口访问**（仅允许管理 IP 访问 18080 端口）
3. **使用正式 SSL 证书**
4. **定期更新镜像**

---

## 📚 相关链接

- [Gost 官方文档](https://gost.run/)
- [Gost UI 项目](https://github.com/go-gost/gost-ui)
- [Gost GitHub](https://github.com/go-gost/gost)

---

## 📄 许可证

MIT License
