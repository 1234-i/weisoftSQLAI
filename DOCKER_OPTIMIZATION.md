# Docker 镜像优化方案

## 📊 当前镜像分析

**当前镜像大小**: 978MB

### 镜像组成分析

1. **基础镜像** (~400MB)
   - `sqlbot-python-pg:latest` - Python 3.11 + PostgreSQL 客户端
   - 包含系统库和运行时环境

2. **Python 依赖** (~450MB)
   - `torch` (175MB) - PyTorch 深度学习框架
   - `scipy` (34MB) - 科学计算库
   - `numpy` (16MB) - 数值计算库
   - `pandas` (12.5MB) - 数据分析库
   - `transformers` (11MB) - Hugging Face 模型库
   - `mypy` (12.6MB) - 类型检查工具
   - `ruff` (12.7MB) - Python linter
   - 其他200+个依赖包

3. **前端构建产物** (~5MB)
   - Vue 3 + Vite 构建后的静态文件
   - 已经过压缩和优化

4. **Node.js 运行时** (~100MB)
   - g2-ssr 服务依赖
   - 168个 npm 包

5. **其他** (~23MB)
   - 字体文件
   - 启动脚本
   - 配置文件

---

## 🎯 优化方案

### 方案 1: 移除开发依赖 (推荐) ⭐

**预计减少**: 50-100MB
**风险**: 低
**影响**: 无

#### 优化内容:
1. 移除类型检查工具 `mypy` (12.6MB)
2. 移除代码检查工具 `ruff` (12.7MB)
3. 移除测试相关依赖
4. 清理 pip 缓存
5. 清理 npm 缓存

#### 实施方法:
```dockerfile
# 在 uv sync 时只安装生产依赖
RUN --mount=type=cache,target=/root/.cache/uv \
   uv sync --extra cpu --no-dev

# 清理缓存
RUN rm -rf /root/.cache/* /tmp/* /var/cache/apt/*
```

---

### 方案 2: 使用 CPU-only PyTorch (中等优化) ⚠️

**预计减少**: 100-150MB
**风险**: 中
**影响**: 如果需要 GPU 加速会受影响

#### 优化内容:
1. 使用 CPU-only 版本的 PyTorch
2. 移除 CUDA 相关库

#### 实施方法:
```toml
# 在 pyproject.toml 中指定 CPU 版本
torch = { version = "^2.0.0", source = "pytorch-cpu" }
```

**注意**: 需要确认 SQLBot 是否需要 GPU 加速功能。

---

### 方案 3: 多阶段构建优化 (推荐) ⭐

**预计减少**: 30-50MB
**风险**: 低
**影响**: 无

#### 优化内容:
1. 在构建阶段清理临时文件
2. 不复制 `.git`、`node_modules` 等无用文件
3. 优化 .dockerignore

#### 实施方法:

**创建/优化 `.dockerignore`**:
```
.git
.gitignore
.venv
__pycache__
*.pyc
*.pyo
*.pyd
.Python
node_modules
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.DS_Store
*.log
.vscode
.idea
*.md
!README.md
docker-build*.log
docker-push*.log
```

**在 Dockerfile 中添加清理步骤**:
```dockerfile
# 构建后清理
RUN rm -rf /tmp/* \
    && rm -rf /root/.cache/* \
    && rm -rf /root/.npm \
    && find /opt/sqlbot -type f -name "*.pyc" -delete \
    && find /opt/sqlbot -type d -name "__pycache__" -delete
```

---

### 方案 4: 压缩层和合并命令 (小幅优化)

**预计减少**: 10-20MB
**风险**: 低
**影响**: 无

#### 优化内容:
1. 合并 RUN 命令减少层数
2. 使用 `--squash` 参数压缩镜像

#### 实施方法:
```bash
# 构建时使用 --squash 参数
docker buildx build --squash ...
```

---

### 方案 5: 使用 Alpine 基础镜像 (激进优化) ⚠️⚠️

**预计减少**: 200-300MB
**风险**: 高
**影响**: 可能导致兼容性问题

#### 优化内容:
1. 使用 `python:3.11-alpine` 替代当前基础镜像
2. 手动安装必要的系统依赖

#### 风险:
- PostgreSQL 客户端库可能不兼容
- 某些 Python 包可能需要编译
- 调试和排错更困难

**不推荐**: 除非有特殊需求,否则不建议使用此方案。

---

## 📋 推荐的优化组合

### 组合 A: 保守优化 (推荐) ⭐⭐⭐

**预计减少**: 80-150MB
**最终大小**: 约 800-900MB
**风险**: 低

**包含方案**:
- ✅ 方案 1: 移除开发依赖
- ✅ 方案 3: 多阶段构建优化
- ✅ 方案 4: 压缩层

**优点**:
- 安全可靠
- 不影响功能
- 易于实施

---

### 组合 B: 激进优化 (不推荐) ⚠️

**预计减少**: 300-400MB
**最终大小**: 约 600-700MB
**风险**: 高

**包含方案**:
- ✅ 方案 1: 移除开发依赖
- ✅ 方案 2: CPU-only PyTorch
- ✅ 方案 3: 多阶段构建优化
- ✅ 方案 4: 压缩层
- ⚠️ 方案 5: Alpine 基础镜像

**缺点**:
- 可能影响功能
- 兼容性风险
- 调试困难

---

## 🚀 实施步骤 (推荐组合 A)

### 步骤 1: 创建优化的 .dockerignore

```bash
cat > .dockerignore << 'EOF'
.git
.gitignore
.venv
__pycache__
*.pyc
*.pyo
*.pyd
.Python
node_modules
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.DS_Store
*.log
.vscode
.idea
docker-build*.log
docker-push*.log
测试数据说明.md
create_test_data.sql
Git分支同步操作指南.md
DOCKER_DEPLOYMENT.md
WEISOFT_README.md
EOF
```

### 步骤 2: 创建优化的 Dockerfile

创建 `Dockerfile.weisoft.optimized`:

```dockerfile
# Build sqlbot with optimizations
FROM registry.cn-qingdao.aliyuncs.com/dataease/sqlbot-base:latest AS sqlbot-builder

ENV PYTHONUNBUFFERED=1
ENV SQLBOT_HOME=/opt/sqlbot
ENV APP_HOME=${SQLBOT_HOME}/app
ENV UI_HOME=${SQLBOT_HOME}/frontend
ENV PYTHONPATH=${SQLBOT_HOME}/app
ENV PATH="${APP_HOME}/.venv/bin:$PATH"
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy
ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p ${APP_HOME} ${UI_HOME}
WORKDIR ${APP_HOME}

# Build frontend
COPY frontend /tmp/frontend
RUN cd /tmp/frontend && \
    npm config set registry https://registry.npmmirror.com && \
    npm install && \
    npm run build && \
    mv dist ${UI_HOME}/dist && \
    rm -rf /tmp/frontend /root/.npm

# Configure pip
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
    pip config set install.trusted-host mirrors.aliyun.com

# Install Python dependencies (production only)
COPY ./backend ${APP_HOME}
RUN --mount=type=cache,target=/root/.cache/uv \
   uv sync --extra cpu --no-dev && \
   find ${APP_HOME} -type f -name "*.pyc" -delete && \
   find ${APP_HOME} -type d -name "__pycache__" -delete && \
   rm -rf /root/.cache/*

# Build g2-ssr
FROM registry.cn-qingdao.aliyuncs.com/dataease/sqlbot-base:latest AS ssr-builder
WORKDIR /app
COPY g2-ssr/app.js g2-ssr/package.json /app/
COPY g2-ssr/charts/* /app/charts/
RUN npm config set registry https://registry.npmmirror.com && \
    npm install --production && \
    rm -rf /root/.npm

# Runtime stage
FROM registry.cn-qingdao.aliyuncs.com/dataease/sqlbot-python-pg:latest

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

ENV PYTHONUNBUFFERED=1
ENV SQLBOT_HOME=/opt/sqlbot
ENV PYTHONPATH=${SQLBOT_HOME}/app
ENV PATH="${SQLBOT_HOME}/app/.venv/bin:$PATH"
ENV POSTGRES_DB=sqlbot
ENV POSTGRES_USER=root
ENV POSTGRES_PASSWORD=Password123@pg

# Copy files
COPY start.sh /opt/sqlbot/app/start.sh
COPY g2-ssr/*.ttf /usr/share/fonts/truetype/liberation/
COPY --from=sqlbot-builder ${SQLBOT_HOME} ${SQLBOT_HOME}
COPY --from=ssr-builder /app /opt/sqlbot/g2-ssr

WORKDIR ${SQLBOT_HOME}/app
RUN mkdir -p /opt/sqlbot/images /opt/sqlbot/g2-ssr && \
    rm -rf /tmp/* /var/cache/apt/*

EXPOSE 3000 8000 8001 5432

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000 || exit 1

ENTRYPOINT ["sh", "start.sh"]
```

### 步骤 3: 构建优化镜像

```bash
docker buildx build \
  --platform linux/amd64 \
  -f Dockerfile.weisoft.optimized \
  -t registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:V1.2.0-optimized \
  --build-arg proxy=taobao \
  --load \
  --progress=plain \
  .
```

### 步骤 4: 对比镜像大小

```bash
docker images | grep weisoftsqlai
```

---

## 📊 预期结果

| 版本 | 大小 | 减少 | 说明 |
|------|------|------|------|
| 当前版本 | 978MB | - | 包含所有依赖 |
| 优化版本 | 约 800-900MB | 80-150MB | 移除开发依赖+清理缓存 |
| 激进版本 | 约 600-700MB | 300-400MB | 不推荐,风险高 |

---

## ⚠️ 注意事项

1. **功能验证**: 优化后务必进行完整的功能测试
2. **备份镜像**: 保留原始镜像以便回滚
3. **渐进优化**: 建议先尝试保守方案,验证无误后再考虑更激进的优化
4. **文档更新**: 更新部署文档中的镜像标签

---

## 🔍 镜像大小对比工具

```bash
# 查看镜像层详情
docker history registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:V1.2.0

# 分析镜像内容
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  wagoodman/dive:latest \
  registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:V1.2.0
```

---

## 📝 总结

**推荐方案**: 组合 A (保守优化)

**理由**:
1. ✅ 安全可靠,不影响功能
2. ✅ 可减少 80-150MB (约 8-15%)
3. ✅ 易于实施和维护
4. ✅ 风险低,易于回滚

**不推荐**: 激进优化方案,除非有特殊需求(如带宽限制、存储限制等)。

**下一步**: 如果需要,我可以帮你实施优化方案并重新构建镜像。

