#!/bin/bash

# WeisoftSQLAI 快速部署脚本

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}WeisoftSQLAI 快速部署脚本${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查 Docker 和 Docker Compose
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker 未安装${NC}"
    echo "请先安装 Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}错误: Docker Compose 未安装${NC}"
    echo "请先安装 Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✅ Docker 环境检查通过${NC}"
echo ""

# 创建数据目录
echo -e "${BLUE}创建数据目录...${NC}"
mkdir -p data/sqlbot/{excel,file,images,logs}
mkdir -p data/postgresql
echo -e "${GREEN}✅ 数据目录创建完成${NC}"
echo ""

# 检查配置文件
if [ ! -f "docker-compose.weisoft.yaml" ]; then
    echo -e "${RED}错误: docker-compose.weisoft.yaml 文件不存在${NC}"
    exit 1
fi

# 提示用户修改配置
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}重要: 请确认以下配置${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""
echo -e "${BLUE}1. 服务器 IP 地址${NC}"
echo -e "   在 docker-compose.weisoft.yaml 中搜索 'YOUR_SERVER_IP'"
echo -e "   替换为实际的服务器 IP 地址"
echo ""
echo -e "${BLUE}2. 域名配置${NC}"
echo -e "   在 docker-compose.weisoft.yaml 中搜索 'YOUR_DOMAIN'"
echo -e "   替换为实际的域名"
echo ""
echo -e "${BLUE}3. 数据库密码${NC}"
echo -e "   建议修改 POSTGRES_PASSWORD 为更安全的密码"
echo ""

read -p "是否已完成配置修改? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}请先修改配置文件,然后重新运行此脚本${NC}"
    exit 0
fi

# 拉取镜像
echo ""
echo -e "${BLUE}拉取 Docker 镜像...${NC}"
docker pull registry.cn-hangzhou.aliyuncs.com/weisoft/weisoftsqlai:V1.2.0

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 镜像拉取失败${NC}"
    echo -e "${YELLOW}提示: 如果镜像尚未推送到阿里云,请先运行 ./build-and-push.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 镜像拉取成功${NC}"
echo ""

# 启动服务
echo -e "${BLUE}启动服务...${NC}"
docker-compose -f docker-compose.weisoft.yaml up -d

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✅ 部署成功!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}服务信息:${NC}"
    echo -e "  主应用: http://YOUR_SERVER_IP:8000"
    echo -e "  MCP 服务: http://YOUR_SERVER_IP:8001"
    echo ""
    echo -e "${YELLOW}默认登录信息:${NC}"
    echo -e "  用户名: admin"
    echo -e "  密码: SQLBot@123456"
    echo ""
    echo -e "${YELLOW}常用命令:${NC}"
    echo -e "  查看日志: docker-compose -f docker-compose.weisoft.yaml logs -f"
    echo -e "  停止服务: docker-compose -f docker-compose.weisoft.yaml down"
    echo -e "  重启服务: docker-compose -f docker-compose.weisoft.yaml restart"
    echo ""
    echo -e "${BLUE}正在等待服务启动(约 30-60 秒)...${NC}"
    sleep 10
    
    # 检查服务状态
    echo ""
    docker-compose -f docker-compose.weisoft.yaml ps
    echo ""
    echo -e "${GREEN}提示: 服务完全启动需要 30-60 秒,请稍后访问${NC}"
else
    echo -e "${RED}❌ 部署失败${NC}"
    echo -e "${YELLOW}请查看日志: docker-compose -f docker-compose.weisoft.yaml logs${NC}"
    exit 1
fi

