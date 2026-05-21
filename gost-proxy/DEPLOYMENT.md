# Gost 代理服务器部署手册 (Amazon Linux 2023)

本文档介绍如何在 Amazon Linux 2023 上使用 Docker 部署 Gost HTTP/HTTPS 代理服务器，使用官方 Gost UI 进行可视化管理。

---

## 📋 目录

1. [系统要求](#系统要求)
2. [环境准备](#环境准备)
3. [安装 Docker](#安装-docker)
4. [部署代理服务](#部署代理服务)
5. [使用 Gost UI 管理界面](#使用-gost-ui-管理界面)
6. [配置说明](#配置说明)
7. [常见问题](#常见问题)

---

## 系统要求

| 项目 | 要求 |
|------|------|
| 操作系统 | Amazon Linux 2023 |
| 内存 | 最低 512MB，推荐 1GB+ |
| 存储 | 最低 10GB |
| 权限 | root 或 sudo 权限 |

---

## 环境准备

### 1. 更新系统

```bash
sudo dnf update -y
```

### 2. 安装必要工具

```bash
sudo dnf install -y git curl wget vim
```

---

## 安装 Docker

### 方法一：官方脚本安装（推荐）

```bash
# 下载 Docker 安装脚本
curl -fsSL https://get.docker.com -o get-docker.sh

# 执行安装
sudo sh get-docker.sh

# 启动 Docker 服务
sudo systemctl start docker
sudo systemctl enable docker

# 验证安装
sudo docker --version
```

### 方法二：手动安装

```bash
# 添加 Docker 仓库
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

# 安装 Docker
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 启动服务
sudo systemctl start docker
sudo systemctl enable docker
```

### 配置 Docker 用户（可选但推荐）

```bash
# 将当前用户添加到 docker 组
sudo usermod -aG docker $USER

# 重新登录使生效
# 或执行: newgrp docker
```

### 验证 Docker 安装

```bash
# 测试 Docker
docker run hello-world

# 查看 Docker 信息
docker info
```

---

## 部署代理服务

### 1. 克隆项目

```bash
# 克隆项目
git clone https://github.com/ywyang/kiro-demos.git
cd kiro-demos/gost-proxy
```

### 2. 项目结构

```
gost-proxy/
├── docker-compose.yml      # Docker 编排配置
├── gost.yaml              # Gost 代理配置
├── README.md              # 项目说明
├── DEPLOYMENT.md          # 本部署手册
├── .env.example           # 环境变量示例
├── .gitignore             # Git 忽略文件
├── scripts/
│   └── generate-certs.sh  # SSL 证书生成脚本
├── certs/                 # SSL 证书目录
└── data/                  # 数据存储目录
```

### 3. 生成 SSL 证书（可选，用于 HTTPS 代理）

```bash
# 添加执行权限
chmod +x scripts/generate-certs.sh

# 生成证书
./scripts/generate-certs.sh
```

> 💡 **提示**: 如果不需要 HTTPS 代理，可以跳过此步骤，并在 `gost.yaml` 中删除 `https-proxy` 服务配置。

### 4. 启动服务

```bash
# 创建数据目录
mkdir -p data certs

# 启动所有服务
docker compose up -d

# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f
```

### 5. 验证服务

```bash
# 检查端口监听
ss -tlnp | grep -E '8080|8443|3000|18080'

# 测试 HTTP 代理
curl -x http://user1:pass123@localhost:8080 http://httpbin.org/ip
```

---

## 使用 Gost UI 管理界面

### 访问方式

Gost UI 提供两种访问方式：

#### 方式一：使用本地部署的 UI（推荐）

1. 打开浏览器访问：`http://服务器IP:3000`
2. 填写连接信息：
   - **API 地址**: `http://服务器IP:18080`
   - **用户名/密码**: 留空（默认未配置 API 认证）
3. 点击 **连接** 按钮

#### 方式二：使用官方在线 UI

1. 打开 https://ui.gost.run
2. 填写连接信息：
   - **API 地址**: `http://服务器IP:18080`
3. 点击 **连接** 按钮

> ⚠️ **注意**: 使用在线 UI 时，确保服务器防火墙已开放 18080 端口。

### Web UI 功能

连接成功后，你可以在 Web UI 中：

- ✅ **服务管理** - 查看、添加、修改、删除代理服务
- ✅ **用户管理** - 动态添加、修改、删除代理用户
- ✅ **链式代理** - 配置多级代理链
- ✅ **实时监控** - 查看服务状态和连接信息
- ✅ **配置导入导出** - 导入导出配置文件

### 添加用户示例

1. 在 Web UI 中选择 `http-proxy` 服务
2. 点击 **编辑** 或找到 **认证** 部分
3. 添加新用户：
   ```json
   {
     "username": "newuser",
     "password": "newpassword"
   }
   ```
4. 保存配置

---

## 配置说明

### 端口说明

| 端口 | 服务 | 说明 |
|------|------|------|
| 8080 | HTTP 代理 | HTTP/HTTPS CONNECT 代理 |
| 8443 | HTTPS 代理 | TLS 加密的代理连接 |
| 3000 | Gost UI | Web 管理界面 |
| 18080 | Gost API | 管理 API（供 UI 连接） |

### 配置文件说明

**gost.yaml** 主要配置：

```yaml
# API 配置 - 供 Web UI 连接
api:
  addr: :18080
  pathPrefix: /api
  accessLog: true

# 服务配置
services:
  - name: http-proxy
    addr: :8080
    handler:
      type: http
      auths:
        - username: user1
          password: pass123
```

### 用户管理方式

| 方式 | 说明 |
|------|------|
| **Web UI** | 推荐方式，动态管理，无需重启 |
| **配置文件** | 编辑 `gost.yaml`，需重启服务 |

---

## 客户端配置

### 浏览器代理设置

1. 打开浏览器代理设置
2. 配置 HTTP 代理：
   - 地址: `服务器IP`
   - 端口: `8080`
3. 配置认证：
   - 用户名/密码: 在 Web UI 创建的用户

### 命令行使用

```bash
# 设置环境变量
export http_proxy=http://user1:pass123@服务器IP:8080
export https_proxy=http://user1:pass123@服务器IP:8080

# 测试
curl http://httpbin.org/ip
```

### Python 使用

```python
import requests

proxies = {
    'http': 'http://user1:pass123@服务器IP:8080',
    'https': 'http://user1:pass123@服务器IP:8080'
}
response = requests.get('https://httpbin.org/ip', proxies=proxies)
print(response.json())
```

---

## AWS 安全组配置

在 AWS 控制台配置安全组规则：

| 类型 | 端口 | 源 | 说明 |
|------|------|-----|------|
| Custom TCP | 8080 | 0.0.0.0/0 或指定 IP | HTTP 代理 |
| Custom TCP | 8443 | 0.0.0.0/0 或指定 IP | HTTPS 代理（可选） |
| Custom TCP | 3000 | 仅管理 IP | Gost UI 管理界面 |
| Custom TCP | 18080 | 仅管理 IP | Gost API |

> ⚠️ **安全建议**: 
> - 18080 (API) 和 3000 (UI) 端口建议限制访问 IP
> - 使用强密码
> - 定期更新用户密码

---

## 服务管理命令

```bash
# 启动服务
docker compose up -d

# 停止服务
docker compose down

# 重启服务
docker compose restart

# 查看日志
docker compose logs -f gost

# 查看特定服务日志
docker compose logs -f gost
docker compose logs -f gost-ui

# 更新镜像
docker compose pull && docker compose up -d

# 完全清理
docker compose down -v
```

---

## 常见问题

### 1. Web UI 无法连接 API

```bash
# 检查 Gost API 是否正常
curl http://localhost:18080/api/services

# 检查防火墙
sudo iptables -L -n

# 检查 AWS 安全组是否开放 18080 端口
```

### 2. 代理认证失败

```bash
# 查看 Gost 日志
docker compose logs gost | grep -i auth

# 检查用户配置
curl http://localhost:18080/api/services
```

### 3. HTTPS 代理证书错误

- 确保证书文件存在于 `certs/` 目录
- 检查 `gost.yaml` 中证书路径是否正确
- 生产环境建议使用正式证书

### 4. Chrome 浏览器无法访问本地 API

Chrome 安全策略限制了 HTTPS 页面访问本地 HTTP API。

解决方案：
1. 使用本地部署的 UI (http://IP:3000)
2. 或修改 Chrome 设置：`chrome://flags/#allow-insecure-localhost`

---

## 性能优化

### Docker 配置优化

编辑 `/etc/docker/daemon.json`:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

重启 Docker：

```bash
sudo systemctl restart docker
```

### 系统参数优化

编辑 `/etc/sysctl.conf`:

```conf
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
```

应用配置：

```bash
sudo sysctl -p
```

---

## 更新升级

```bash
# 拉取最新镜像
docker compose pull

# 重新启动
docker compose up -d

# 清理旧镜像
docker image prune -f
```

---

## 相关链接

- [Gost 官方文档](https://gost.run/)
- [Gost UI GitHub](https://github.com/go-gost/gost-ui)
- [Gost GitHub](https://github.com/go-gost/gost)

---

**祝使用愉快！🎉**
