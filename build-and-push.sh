#!/bin/bash

# WeisoftSQLAI Docker 构建和推送脚本
# 使用淘宝镜像加速构建

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置变量
IMAGE_NAME="registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai"
VERSION="V1.2.0"
DOCKERFILE="Dockerfile.weisoft"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}WeisoftSQLAI Docker 构建脚本${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}镜像名称:${NC} ${IMAGE_NAME}"
echo -e "${YELLOW}版本标签:${NC} ${VERSION}"
echo -e "${YELLOW}Dockerfile:${NC} ${DOCKERFILE}"
echo ""

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker 未安装或未在 PATH 中${NC}"
    exit 1
fi

# 检查 Dockerfile 是否存在
if [ ! -f "${DOCKERFILE}" ]; then
    echo -e "${RED}错误: ${DOCKERFILE} 文件不存在${NC}"
    exit 1
fi

# 询问是否继续
read -p "是否开始构建? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}构建已取消${NC}"
    exit 0
fi

# 开始构建
echo -e "${GREEN}开始构建 Docker 镜像...${NC}"
echo -e "${YELLOW}注意: 构建过程可能需要 10-30 分钟,请耐心等待${NC}"
echo ""

# 构建镜像
docker build \
    -f ${DOCKERFILE} \
    -t ${IMAGE_NAME}:${VERSION} \
    -t ${IMAGE_NAME}:latest \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --progress=plain \
    .

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Docker 镜像构建成功!${NC}"
    echo ""
    echo -e "${YELLOW}镜像信息:${NC}"
    docker images | grep weisoftsqlai
    echo ""
else
    echo -e "${RED}❌ Docker 镜像构建失败${NC}"
    exit 1
fi

# 询问是否推送到阿里云
read -p "是否推送镜像到阿里云? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}推送已取消${NC}"
    echo -e "${GREEN}本地镜像已构建完成,可以使用以下命令运行:${NC}"
    echo -e "  docker-compose -f docker-compose.weisoft.yaml up -d"
    exit 0
fi

# 登录阿里云容器镜像服务
echo ""
echo -e "${GREEN}登录阿里云容器镜像服务...${NC}"
echo -e "${YELLOW}请输入阿里云容器镜像服务的用户名和密码${NC}"
echo ""

docker login --username=YOUR_ALIYUN_USERNAME registry.cn-hangzhou.aliyuncs.com

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 登录失败,请检查用户名和密码${NC}"
    exit 1
fi

# 推送镜像
echo ""
echo -e "${GREEN}推送镜像到阿里云...${NC}"
echo -e "${YELLOW}推送版本: ${VERSION}${NC}"

docker push ${IMAGE_NAME}:${VERSION}

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 版本 ${VERSION} 推送成功${NC}"
else
    echo -e "${RED}❌ 版本 ${VERSION} 推送失败${NC}"
    exit 1
fi

# 推送 latest 标签
echo ""
echo -e "${YELLOW}推送 latest 标签...${NC}"

docker push ${IMAGE_NAME}:latest

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ latest 标签推送成功${NC}"
else
    echo -e "${RED}❌ latest 标签推送失败${NC}"
    exit 1
fi

# 完成
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ 所有操作完成!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}镜像信息:${NC}"
echo -e "  ${IMAGE_NAME}:${VERSION}"
echo -e "  ${IMAGE_NAME}:latest"
echo ""
echo -e "${YELLOW}部署命令:${NC}"
echo -e "  docker pull ${IMAGE_NAME}:${VERSION}"
echo -e "  docker-compose -f docker-compose.weisoft.yaml up -d"
echo ""
echo -e "${YELLOW}查看日志:${NC}"
echo -e "  docker-compose -f docker-compose.weisoft.yaml logs -f"
echo ""

