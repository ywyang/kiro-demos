# Gost HTTP 代理服务器（Kiro IDE 代理）

基于 Docker 的 Gost 代理服务器，为 Kiro IDE/CLI 提供 HTTP 代理服务，使用官方 Gost UI 进行可视化管理。

---

## ✨ 功能特性

- 🔐 **用户认证** - 支持多用户管理，独立密码
- 🌐 **HTTP 代理** - 支持 HTTP CONNECT 隧道（Kiro 所需）
- 📊 **官方 Web UI** - 使用 [Gost UI](https://github.com/go-gost/gost-ui) 可视化管理
- 🐳 **Docker 部署** - 一键启动，方便迁移
- 🔧 **动态配置** - 通过 Web UI 动态管理用户和服务

---

## 📁 项目结构

```
gost-proxy/
├── docker-compose.yml      # Docker 编排配置
├── gost.yaml              # Gost 代理配置
├── .env.example           # 环境变量示例
├── DEPLOYMENT.md          # 详细部署文档 (Amazon Linux 2023)
└── README.md              # 本文件
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

### 3. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 修改 API 认证密码（可选）
```

### 4. 启动服务

```bash
docker compose up -d
```

### 5. 访问服务

| 服务 | 地址 | 说明 |
|------|------|------|
| **Gost UI** | http://localhost:3000 | Web 管理界面 |
| HTTP 代理 | localhost:8080 | HTTP/HTTPS 代理（CONNECT 隧道） |

---

## 🖥️ 配置 Kiro IDE/CLI 使用代理

### 环境变量方式

```bash
export HTTP_PROXY=http://user1:pass123@代理服务器IP:8080
export HTTPS_PROXY=http://user1:pass123@代理服务器IP:8080
```

然后启动 Kiro CLI：

```bash
kiro-cli chat
```

### 持久化配置（写入 shell profile）

```bash
echo 'export HTTP_PROXY=http://user1:pass123@代理服务器IP:8080' >> ~/.bashrc
echo 'export HTTPS_PROXY=http://user1:pass123@代理服务器IP:8080' >> ~/.bashrc
source ~/.bashrc
```

> ⚠️ **注意**: Kiro 登录时会打开浏览器访问 `app.kiro.dev`，浏览器流量不走 CLI 代理。确保浏览器所在网络能直接访问 `app.kiro.dev`。

---

## 📖 使用 Web UI 管理

### 连接到 Gost

1. 打开 http://localhost:3000
2. 填写连接信息：
   - **API 地址**: `http://服务器IP:18080`
   - **用户名**: `admin`（见 `gost.yaml` 中 `api.auth.username`）
   - **密码**: 你设置的密码（见 `gost.yaml` 中 `api.auth.password`）
3. 点击 **连接** 按钮

> 💡 **提示**: 也可以使用官方在线 UI: https://ui.gost.run

---

## 🌐 Kiro 需要访问的域名

代理服务器需要能访问以下域名（出站）：

| 域名 | 用途 |
|------|------|
| `*.kiro.dev` | Kiro 核心服务 |
| `q.us-east-1.amazonaws.com` | Kiro 服务 (US East) |
| `q.eu-central-1.amazonaws.com` | Kiro 服务 (Europe) |
| `cognito-identity.us-east-1.amazonaws.com` | 社交登录 |

完整列表参考: [Kiro 防火墙配置文档](https://kiro.dev/docs/cli/privacy-and-security/firewalls/)

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

## 🔒 安全建议

1. **修改默认用户密码**
2. **修改 API 认证密码**（`gost.yaml` 中的 `api.auth`）
3. **限制 API 端口访问**（仅允许管理 IP 访问 18080 端口）
4. **定期更新镜像**

---

## 📖 详细部署文档

完整部署指南（Amazon Linux 2023）请查看: [DEPLOYMENT.md](./DEPLOYMENT.md)

---

## 📚 相关链接

- [Gost 官方文档](https://gost.run/)
- [Gost UI 项目](https://github.com/go-gost/gost-ui)
- [Kiro 代理配置文档](https://kiro.dev/docs/cli/privacy-and-security/firewalls/)

---

## 📄 许可证

MIT License
