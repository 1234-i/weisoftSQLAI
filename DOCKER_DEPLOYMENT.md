# WeisoftSQLAI Docker 部署指南

## 📋 目录

1. [构建 Docker 镜像](#构建-docker-镜像)
2. [推送到阿里云](#推送到阿里云)
3. [部署说明](#部署说明)
4. [配置说明](#配置说明)
5. [常见问题](#常见问题)

---

## 🚀 构建 Docker 镜像

### 方法一: 使用自动化脚本(推荐)

```bash
# 1. 赋予脚本执行权限
chmod +x build-and-push.sh

# 2. 运行构建脚本
./build-and-push.sh
```

脚本会自动完成以下操作:
- ✅ 使用淘宝镜像加速构建
- ✅ 构建 Docker 镜像
- ✅ 打上版本标签 (V1.2.0 和 latest)
- ✅ 推送到阿里云容器镜像服务

### 方法二: 手动构建

```bash
# 1. 构建镜像
docker build \
  -f Dockerfile.weisoft \
  -t registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:V1.2.0 \
  -t registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:latest \
  .

# 2. 查看构建的镜像
docker images | grep weisoftsqlai
```

**注意事项:**
- 构建过程需要 10-30 分钟,取决于网络速度和机器性能
- 确保有足够的磁盘空间(至少 10GB)
- 使用淘宝镜像可以显著加快构建速度

---

## ☁️ 推送到阿里云

### 1. 登录阿里云容器镜像服务

```bash
# 登录阿里云杭州区域
docker login --username=YOUR_USERNAME registry.cn-hangzhou.aliyuncs.com
```

**获取登录凭证:**
1. 访问 [阿里云容器镜像服务控制台](https://cr.console.aliyun.com/)
2. 点击左侧菜单 "访问凭证"
3. 设置或重置密码
4. 使用阿里云账号和密码登录

### 2. 推送镜像

```bash
# 推送版本标签
docker push registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:V1.2.0

# 推送 latest 标签
docker push registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:latest
```

### 3. 验证推送

访问阿里云容器镜像服务控制台,在 "镜像仓库" 中查看是否有 `weisoft/weisoftsqlai` 仓库。

---

## 📦 部署说明

### 前置要求

- Docker 20.10+
- Docker Compose 2.0+
- 至少 4GB 可用内存
- 至少 20GB 可用磁盘空间

### 快速部署

```bash
# 1. 创建数据目录
mkdir -p data/sqlbot/{excel,file,images,logs}
mkdir -p data/postgresql

# 2. 修改配置文件
# 编辑 docker-compose.weisoft.yaml,修改以下配置:
# - YOUR_SERVER_IP: 替换为实际的服务器IP
# - YOUR_DOMAIN: 替换为实际的域名
# - POSTGRES_PASSWORD: 修改数据库密码(可选)

# 3. 启动服务
docker-compose -f docker-compose.weisoft.yaml up -d

# 4. 查看日志
docker-compose -f docker-compose.weisoft.yaml logs -f

# 5. 检查服务状态
docker-compose -f docker-compose.weisoft.yaml ps
```

### 访问应用

- **主应用**: http://YOUR_SERVER_IP:8000
- **MCP 服务**: http://YOUR_SERVER_IP:8001
- **PostgreSQL**: YOUR_SERVER_IP:5432

**默认登录信息:**
- 用户名: `admin`
- 密码: `SQLBot@123456`

---

## ⚙️ 配置说明

### 环境变量配置

在 `docker-compose.weisoft.yaml` 中可以配置以下环境变量:

#### 数据库配置

```yaml
POSTGRES_SERVER: localhost        # 数据库服务器地址
POSTGRES_PORT: 5432               # 数据库端口
POSTGRES_DB: sqlbot               # 数据库名称
POSTGRES_USER: root               # 数据库用户名
POSTGRES_PASSWORD: Password123@pg # 数据库密码(建议修改)
```

#### 应用配置

```yaml
PROJECT_NAME: "weisoft SQLAI"     # 项目名称
DEFAULT_PWD: "SQLBot@123456"      # 默认密码
SECRET_KEY: y5txe1mRmS_...        # JWT 密钥(建议修改)
```

#### CORS 配置

```yaml
BACKEND_CORS_ORIGINS: "http://localhost,http://YOUR_DOMAIN,https://YOUR_DOMAIN"
```

**重要:** 根据实际部署的域名修改 CORS 配置,多个域名用逗号分隔。

#### MCP 配置

```yaml
SERVER_IMAGE_HOST: http://YOUR_SERVER_IP:8001/images/
```

**重要:** 替换 `YOUR_SERVER_IP` 为实际的服务器 IP 地址。

### 数据持久化

以下目录会被持久化到宿主机:

```yaml
volumes:
  - ./data/sqlbot/excel:/opt/sqlbot/data/excel          # Excel 文件
  - ./data/sqlbot/file:/opt/sqlbot/data/file            # 上传文件
  - ./data/sqlbot/images:/opt/sqlbot/images             # 图片文件
  - ./data/sqlbot/logs:/opt/sqlbot/app/logs             # 应用日志
  - ./data/postgresql:/var/lib/postgresql/data          # 数据库数据
```

**备份建议:**
- 定期备份 `./data` 目录
- 特别注意备份 `./data/postgresql` 数据库目录

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

# 查看特定服务日志
docker logs -f weisoftsqlai
```

### 镜像管理

```bash
# 拉取最新镜像
docker pull registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:V1.2.0

# 查看本地镜像
docker images | grep weisoftsqlai

# 删除旧镜像
docker rmi registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:old_version
```

### 数据库管理

```bash
# 进入容器
docker exec -it weisoftsqlai bash

# 连接数据库
docker exec -it weisoftsqlai psql -U root -d sqlbot

# 备份数据库
docker exec weisoftsqlai pg_dump -U root sqlbot > backup_$(date +%Y%m%d).sql

# 恢复数据库
docker exec -i weisoftsqlai psql -U root -d sqlbot < backup_20250102.sql
```

---

## ❓ 常见问题

### 1. 构建失败: npm install 超时

**原因:** 网络问题导致 npm 包下载失败

**解决方案:**
```bash
# Dockerfile.weisoft 已配置淘宝镜像,如果仍然失败,可以尝试:
# 1. 检查网络连接
# 2. 使用代理
# 3. 手动下载依赖后再构建
```

### 2. 容器启动失败: 端口被占用

**错误信息:** `Bind for 0.0.0.0:8000 failed: port is already allocated`

**解决方案:**
```bash
# 1. 查看端口占用
lsof -i :8000

# 2. 修改 docker-compose.weisoft.yaml 中的端口映射
ports:
  - "8080:8000"  # 将宿主机端口改为 8080
```

### 3. 数据库连接失败

**错误信息:** `could not connect to server: Connection refused`

**解决方案:**
```bash
# 1. 检查数据库是否启动
docker exec weisoftsqlai pg_isready -U root

# 2. 查看数据库日志
docker logs weisoftsqlai | grep postgres

# 3. 等待数据库完全启动(约 30-60 秒)
```

### 4. 前端页面无法访问

**可能原因:**
1. 容器未完全启动
2. CORS 配置错误
3. 防火墙阻止

**解决方案:**
```bash
# 1. 检查容器状态
docker-compose -f docker-compose.weisoft.yaml ps

# 2. 检查健康状态
docker inspect weisoftsqlai | grep Health

# 3. 查看应用日志
docker logs weisoftsqlai | tail -100

# 4. 检查防火墙
sudo firewall-cmd --list-ports  # CentOS/RHEL
sudo ufw status                 # Ubuntu
```

### 5. 内存不足

**错误信息:** `Cannot allocate memory`

**解决方案:**
```yaml
# 在 docker-compose.weisoft.yaml 中调整资源限制
deploy:
  resources:
    limits:
      memory: 4G  # 降低内存限制
```

---

## 📞 技术支持

如有问题,请联系:
- 公司: 上海未软人工智能科技有限公司
- 邮箱: support@weisoft.com
- 电话: XXX-XXXX-XXXX

---

## 📝 更新日志

### V1.2.0 (2025-01-02)
- ✅ 修改版权信息为上海未软人工智能科技有限公司
- ✅ 移除帮助菜单
- ✅ 更新到官方 v1.2 版本
- ✅ 使用淘宝镜像加速构建
- ✅ 优化 Docker 配置

