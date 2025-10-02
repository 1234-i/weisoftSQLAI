# weisoft SQLAI 部署验证指南

## 📦 镜像信息

**镜像地址**: `registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:V1.2.0`
**镜像大小**: 978MB
**版本**: v1.2.0
**平台**: linux/amd64

---

## 🚀 快速部署

### 方法 1: 使用 docker-compose (推荐)

#### 步骤 1: 准备配置文件

```bash
# 查看配置文件
cat docker-compose.weisoft.yaml
```

#### 步骤 2: 修改配置 (重要!)

编辑 `docker-compose.weisoft.yaml`,修改以下内容:

```yaml
environment:
  # 修改为你的服务器IP或域名
  SERVER_IMAGE_HOST: "http://YOUR_SERVER_IP:8001/images/"
  
  # 修改CORS允许的域名
  BACKEND_CORS_ORIGINS: "http://localhost,http://YOUR_DOMAIN"
  
  # 修改数据库密码(可选,建议修改)
  POSTGRES_PASSWORD: "YOUR_STRONG_PASSWORD"
```

#### 步骤 3: 创建数据目录

```bash
mkdir -p data/sqlbot/excel
mkdir -p data/sqlbot/file
mkdir -p data/sqlbot/images
mkdir -p data/sqlbot/logs
mkdir -p data/postgresql
```

#### 步骤 4: 启动服务

```bash
# 启动服务
docker-compose -f docker-compose.weisoft.yaml up -d

# 查看日志
docker-compose -f docker-compose.weisoft.yaml logs -f

# 查看服务状态
docker-compose -f docker-compose.weisoft.yaml ps
```

#### 步骤 5: 停止服务

```bash
# 停止服务
docker-compose -f docker-compose.weisoft.yaml down

# 停止并删除数据卷
docker-compose -f docker-compose.weisoft.yaml down -v
```

---

### 方法 2: 使用快速部署脚本

```bash
# 执行快速部署脚本
./quick-deploy.sh

# 脚本会自动:
# 1. 检查 Docker 环境
# 2. 创建数据目录
# 3. 启动服务
# 4. 显示访问地址
```

---

### 方法 3: 直接运行容器

```bash
docker run -d \
  --name weisoftsqlai \
  --restart unless-stopped \
  -p 8000:8000 \
  -p 8001:8001 \
  -e PROJECT_NAME="weisoft SQLAI" \
  -e POSTGRES_PASSWORD="Password123@pg" \
  -e SERVER_IMAGE_HOST="http://YOUR_SERVER_IP:8001/images/" \
  -e BACKEND_CORS_ORIGINS="http://localhost,http://YOUR_DOMAIN" \
  -v $(pwd)/data/sqlbot/excel:/opt/sqlbot/data/excel \
  -v $(pwd)/data/sqlbot/file:/opt/sqlbot/data/file \
  -v $(pwd)/data/sqlbot/images:/opt/sqlbot/images \
  -v $(pwd)/data/sqlbot/logs:/opt/sqlbot/app/logs \
  -v $(pwd)/data/postgresql:/var/lib/postgresql/data \
  --privileged=true \
  registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:V1.2.0
```

---

## 🔍 验证部署

### 1. 检查容器状态

```bash
# 查看容器是否运行
docker ps | grep weisoftsqlai

# 查看容器日志
docker logs -f weisoftsqlai

# 查看容器详情
docker inspect weisoftsqlai
```

### 2. 检查端口监听

```bash
# 检查端口是否开放
netstat -tuln | grep -E "8000|8001"

# 或使用 lsof
lsof -i :8000
lsof -i :8001
```

### 3. 访问前端界面

打开浏览器访问:

```
http://localhost:8000/
或
http://YOUR_SERVER_IP:8000/
```

**默认登录信息**:
- 用户名: `admin`
- 密码: `SQLBot@123456`

### 4. 验证 API 接口

```bash
# 健康检查
curl http://localhost:8000/health

# API 文档
curl http://localhost:8000/docs

# 版本信息
curl http://localhost:8000/api/v1/system/version
```

### 5. 验证数据库

```bash
# 进入容器
docker exec -it weisoftsqlai bash

# 连接数据库
psql -U root -d sqlbot

# 查看表
\dt

# 查看管理员信息
SELECT id, account, name, email FROM core_user WHERE account='admin';

# 退出
\q
exit
```

**预期结果**:
- 管理员邮箱应该是: `admin@weisoft.com`

---

## ✅ 功能验证清单

### 前端验证

登录后,依次验证以下功能:

- [ ] **登录功能** - 使用 admin/SQLBot@123456 登录
- [ ] **主题颜色** - 确认主题色为 #6366F1 (紫色)
- [ ] **关于页面** - 点击右上角头像 -> "关于"
  - [ ] 版权信息: "2024-2025 © 上海未软人工智能科技有限公司"
  - [ ] 版本号: v1.2 (如果显示 v1.1.4,需要重启服务)
  - [ ] 确认没有"帮助"菜单项
- [ ] **数据源管理** - 添加测试数据源
- [ ] **助手管理** - 创建测试助手
- [ ] **对话功能** - 测试问数功能

### 后端验证

```bash
# 1. 检查后端日志
docker logs weisoftsqlai | grep -i "error\|exception"

# 2. 检查数据库连接
docker exec weisoftsqlai psql -U root -d sqlbot -c "SELECT version();"

# 3. 检查 Python 环境
docker exec weisoftsqlai python --version

# 4. 检查依赖包
docker exec weisoftsqlai pip list | grep -E "torch|transformers|langchain"
```

---

## 🐛 常见问题

### 问题 1: 容器启动失败

**症状**: `docker ps` 看不到容器

**解决方法**:
```bash
# 查看容器日志
docker logs weisoftsqlai

# 常见原因:
# 1. 端口被占用 - 修改端口映射
# 2. 数据目录权限问题 - 检查目录权限
# 3. 数据库初始化失败 - 删除数据目录重新启动
```

### 问题 2: 无法访问前端

**症状**: 浏览器无法打开 http://localhost:8000/

**解决方法**:
```bash
# 1. 检查容器是否运行
docker ps | grep weisoftsqlai

# 2. 检查端口映射
docker port weisoftsqlai

# 3. 检查防火墙
sudo ufw status
sudo ufw allow 8000
sudo ufw allow 8001

# 4. 检查 CORS 配置
docker exec weisoftsqlai env | grep CORS
```

### 问题 3: 版本号显示错误

**症状**: 关于页面显示 v1.1.4 而不是 v1.2

**解决方法**:
```bash
# 重启容器
docker restart weisoftsqlai

# 或者重新部署
docker-compose -f docker-compose.weisoft.yaml down
docker-compose -f docker-compose.weisoft.yaml up -d
```

### 问题 4: 数据库连接失败

**症状**: 日志显示数据库连接错误

**解决方法**:
```bash
# 1. 检查数据库是否启动
docker exec weisoftsqlai pg_isready -U root

# 2. 检查数据库密码
docker exec weisoftsqlai env | grep POSTGRES

# 3. 重新初始化数据库
docker-compose -f docker-compose.weisoft.yaml down -v
rm -rf data/postgresql/*
docker-compose -f docker-compose.weisoft.yaml up -d
```

### 问题 5: 镜像拉取失败

**症状**: 在其他服务器上拉取镜像失败

**解决方法**:
```bash
# 1. 登录阿里云
docker login --username=YOUR_USERNAME registry.cn-hangzhou.aliyuncs.com

# 2. 检查网络连接
ping registry.cn-hangzhou.aliyuncs.com

# 3. 使用代理(如果需要)
export HTTP_PROXY=http://proxy:port
export HTTPS_PROXY=http://proxy:port

# 4. 重新拉取
docker pull registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:V1.2.0
```

---

## 📊 性能监控

### 查看资源使用

```bash
# 查看容器资源使用
docker stats weisoftsqlai

# 查看容器进程
docker top weisoftsqlai

# 查看磁盘使用
du -sh data/
```

### 日志管理

```bash
# 查看实时日志
docker logs -f weisoftsqlai

# 查看最后100行日志
docker logs --tail 100 weisoftsqlai

# 查看特定时间的日志
docker logs --since 2024-10-02T10:00:00 weisoftsqlai

# 清理日志
docker logs weisoftsqlai > /dev/null 2>&1
```

---

## 🔄 更新升级

### 升级到新版本

```bash
# 1. 停止当前服务
docker-compose -f docker-compose.weisoft.yaml down

# 2. 备份数据
tar -czf backup-$(date +%Y%m%d).tar.gz data/

# 3. 拉取新版本镜像
docker pull registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:latest

# 4. 启动新版本
docker-compose -f docker-compose.weisoft.yaml up -d

# 5. 验证升级
docker logs -f weisoftsqlai
```

### 回滚到旧版本

```bash
# 1. 停止服务
docker-compose -f docker-compose.weisoft.yaml down

# 2. 修改 docker-compose.weisoft.yaml 中的镜像标签
# image: registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:V1.1.4

# 3. 启动旧版本
docker-compose -f docker-compose.weisoft.yaml up -d
```

---

## 🔐 安全建议

### 1. 修改默认密码

```bash
# 登录后立即修改管理员密码
# 在前端界面: 右上角头像 -> 修改密码
```

### 2. 修改数据库密码

```yaml
# 在 docker-compose.weisoft.yaml 中修改
environment:
  POSTGRES_PASSWORD: "YOUR_STRONG_PASSWORD"
```

### 3. 配置 HTTPS

```bash
# 使用 Nginx 反向代理
# 配置 SSL 证书
# 修改 BACKEND_CORS_ORIGINS 为 https 地址
```

### 4. 限制访问

```bash
# 使用防火墙限制访问
sudo ufw allow from YOUR_IP to any port 8000
sudo ufw allow from YOUR_IP to any port 8001
```

---

## 📝 备份恢复

### 备份数据

```bash
# 备份所有数据
tar -czf sqlbot-backup-$(date +%Y%m%d).tar.gz data/

# 仅备份数据库
docker exec weisoftsqlai pg_dump -U root sqlbot > sqlbot-db-$(date +%Y%m%d).sql
```

### 恢复数据

```bash
# 恢复所有数据
tar -xzf sqlbot-backup-20241002.tar.gz

# 恢复数据库
docker exec -i weisoftsqlai psql -U root sqlbot < sqlbot-db-20241002.sql
```

---

## 📞 技术支持

如果遇到问题,请提供以下信息:

1. **系统信息**:
   ```bash
   uname -a
   docker --version
   docker-compose --version
   ```

2. **容器日志**:
   ```bash
   docker logs weisoftsqlai > logs.txt
   ```

3. **错误截图**: 前端界面的错误信息

4. **配置文件**: docker-compose.weisoft.yaml (隐藏敏感信息)

---

## ✅ 部署成功标志

当你看到以下内容时,说明部署成功:

1. ✅ 容器状态为 `Up`
2. ✅ 可以访问 http://localhost:8000/
3. ✅ 可以使用 admin/SQLBot@123456 登录
4. ✅ 关于页面显示正确的版权信息
5. ✅ 可以添加数据源和创建助手
6. ✅ 可以进行问数对话

**恭喜!weisoft SQLAI 部署成功!** 🎉

