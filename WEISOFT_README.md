# WeisoftSQLAI - Docker 构建和部署指南

## 📦 项目概述

WeisoftSQLAI 是基于 SQLBot v1.2 定制开发的智能问数平台,由上海未软人工智能科技有限公司维护。

**版本信息:**
- 版本: V1.2.0
- 基于: SQLBot v1.2
- 定制内容:
  - ✅ 修改版权信息为上海未软人工智能科技有限公司
  - ✅ 移除帮助菜单
  - ✅ 使用淘宝镜像加速构建

---

## 🚀 快速开始

### 方式一: 使用自动化脚本(推荐)

#### 1. 构建并推送到阿里云

```bash
# 运行构建脚本
./build-and-push.sh
```

脚本会自动完成:
- ✅ 构建 Docker 镜像(使用淘宝镜像加速)
- ✅ 打上版本标签 (V1.2.0 和 latest)
- ✅ 登录阿里云容器镜像服务
- ✅ 推送镜像到阿里云

#### 2. 部署到服务器

```bash
# 运行快速部署脚本
./quick-deploy.sh
```

脚本会自动完成:
- ✅ 检查 Docker 环境
- ✅ 创建数据目录
- ✅ 拉取镜像
- ✅ 启动服务

### 方式二: 手动操作

#### 1. 构建镜像

```bash
docker build \
  -f Dockerfile.weisoft \
  -t registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:V1.2.0 \
  -t registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:latest \
  .
```

#### 2. 推送到阿里云

```bash
# 登录阿里云
docker login --username=YOUR_USERNAME registry.cn-hangzhou.aliyuncs.com

# 推送镜像
docker push registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:V1.2.0
docker push registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:latest
```

#### 3. 部署

```bash
# 创建数据目录
mkdir -p data/sqlbot/{excel,file,images,logs}
mkdir -p data/postgresql

# 修改配置文件
# 编辑 docker-compose.weisoft.yaml

# 启动服务
docker-compose -f docker-compose.weisoft.yaml up -d
```

---

## 📁 文件说明

### 核心文件

| 文件名 | 说明 |
|--------|------|
| `Dockerfile.weisoft` | Docker 构建文件(使用淘宝镜像) |
| `docker-compose.weisoft.yaml` | Docker Compose 部署配置 |
| `build-and-push.sh` | 自动化构建和推送脚本 |
| `quick-deploy.sh` | 快速部署脚本 |
| `DOCKER_DEPLOYMENT.md` | 详细部署文档 |

### 配置文件

| 文件名 | 说明 |
|--------|------|
| `backend/pyproject.toml` | Python 项目配置(版本: 1.2.0) |
| `frontend/package.json` | 前端项目配置 |
| `.dockerignore` | Docker 构建忽略文件 |

---

## ⚙️ 配置说明

### 必须修改的配置

在 `docker-compose.weisoft.yaml` 中修改以下配置:

```yaml
environment:
  # 1. MCP 服务地址 - 替换为实际的服务器 IP
  SERVER_IMAGE_HOST: http://YOUR_SERVER_IP:8001/images/
  
  # 2. CORS 配置 - 替换为实际的域名
  BACKEND_CORS_ORIGINS: "http://localhost,http://YOUR_DOMAIN,https://YOUR_DOMAIN"
  
  # 3. 数据库密码 - 建议修改为更安全的密码
  POSTGRES_PASSWORD: Password123@pg
  
  # 4. JWT 密钥 - 建议修改为随机字符串
  SECRET_KEY: y5txe1mRmS_JpOrUzFzHEu-kIQn3lf7ll0AOv9DQh0s
```

### 可选配置

```yaml
environment:
  # 项目名称
  PROJECT_NAME: "weisoft SQLAI"
  
  # 默认密码
  DEFAULT_PWD: "SQLBot@123456"
  
  # 日志级别
  LOG_LEVEL: "INFO"
  
  # SQL 调试
  SQL_DEBUG: "False"
```

---

## 🔧 常用命令

### 服务管理

```bash
# 启动服务
docker-compose -f docker-compose.weisoft.yaml up -d

# 停止服务
docker-compose -f docker-compose.weisoft.yaml down

# 重启服务
docker-compose -f docker-compose.weisoft.yaml restart

# 查看服务状态
docker-compose -f docker-compose.weisoft.yaml ps

# 查看日志
docker-compose -f docker-compose.weisoft.yaml logs -f
```

### 镜像管理

```bash
# 拉取镜像
docker pull registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:V1.2.0

# 查看镜像
docker images | grep weisoftsqlai

# 删除镜像
docker rmi registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:V1.2.0
```

### 数据库管理

```bash
# 进入容器
docker exec -it weisoftsqlai bash

# 连接数据库
docker exec -it weisoftsqlai psql -U root -d sqlbot

# 备份数据库
docker exec weisoftsqlai pg_dump -U root sqlbot > backup.sql

# 恢复数据库
docker exec -i weisoftsqlai psql -U root -d sqlbot < backup.sql
```

---

## 🌐 访问应用

部署成功后,可以通过以下地址访问:

- **主应用**: http://YOUR_SERVER_IP:8000
- **MCP 服务**: http://YOUR_SERVER_IP:8001

**默认登录信息:**
- 用户名: `admin`
- 密码: `SQLBot@123456`

---

## 📊 系统要求

### 最低配置

- CPU: 2 核
- 内存: 4GB
- 磁盘: 20GB
- 操作系统: Linux (推荐 Ubuntu 20.04+, CentOS 7+)

### 推荐配置

- CPU: 4 核
- 内存: 8GB
- 磁盘: 50GB
- 操作系统: Linux (推荐 Ubuntu 22.04, CentOS 8+)

### 软件要求

- Docker: 20.10+
- Docker Compose: 2.0+

---

## 🐛 故障排查

### 1. 构建失败

**问题**: npm install 超时

**解决方案**:
```bash
# Dockerfile.weisoft 已配置淘宝镜像
# 如果仍然失败,检查网络连接或使用代理
```

### 2. 端口被占用

**问题**: `Bind for 0.0.0.0:8000 failed`

**解决方案**:
```bash
# 修改 docker-compose.weisoft.yaml 中的端口
ports:
  - "8080:8000"  # 改为其他端口
```

### 3. 数据库连接失败

**问题**: `could not connect to server`

**解决方案**:
```bash
# 等待数据库启动(约 30-60 秒)
docker logs weisoftsqlai | grep postgres
```

### 4. 内存不足

**问题**: `Cannot allocate memory`

**解决方案**:
```yaml
# 在 docker-compose.weisoft.yaml 中降低内存限制
deploy:
  resources:
    limits:
      memory: 4G
```

---

## 📝 更新日志

### V1.2.0 (2025-01-02)

**新功能:**
- ✅ 基于 SQLBot v1.2 定制开发
- ✅ 使用淘宝镜像加速构建

**界面修改:**
- ✅ 修改版权信息为"2024-2025 © 上海未软人工智能科技有限公司"
- ✅ 移除帮助菜单

**优化:**
- ✅ 优化 Docker 构建流程
- ✅ 添加自动化构建和部署脚本
- ✅ 完善部署文档

---

## 📞 技术支持

**公司**: 上海未软人工智能科技有限公司

**联系方式**:
- 邮箱: support@weisoft.com
- 电话: XXX-XXXX-XXXX
- 网站: https://www.weisoft.com

---

## 📄 许可证

本项目基于 SQLBot 开源项目定制开发,遵循原项目的许可证。

定制部分版权归上海未软人工智能科技有限公司所有。

---

## 🙏 致谢

感谢 [DataEase](https://github.com/dataease) 团队开发的 [SQLBot](https://github.com/dataease/SQLBot) 项目。

